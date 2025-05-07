#!/bin/bash

PASTA=${1:-.}
SAIDA=${2:-lista_com_labels.txt}

echo "🗂️  Gerando lista com label, CAN e FORM a partir dos XMLs..."
echo "" > "$SAIDA"

for file in "$PASTA"/*.xml; do
  nome_arquivo=$(basename "$file")

  label=$(grep -oP '(?<=<label>).*?(?=</label>)' "$file")

  # Extrai o valor da <value> quando <field>CAN</field> aparece antes
  can=$(awk '
    /<field>CAN<\/field>/ {getline; match($0, /<value.*>(.*)<\/value>/, a); print a[1]}
  ' "$file")

  # Extrai o valor da <value> quando <field>FORM</field> aparece antes
  form=$(awk '
    /<field>FORM<\/field>/ {getline; match($0, /<value.*>(.*)<\/value>/, a); print a[1]}
  ' "$file")

  echo "${nome_arquivo}|${label}|${can}|${form}" >> "$SAIDA"
done

echo "✅ Lista salva em: $SAIDA"
