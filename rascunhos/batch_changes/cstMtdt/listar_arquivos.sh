#!/bin/bash

PASTA=${1:-.}
SAIDA=${2:-lista_com_labels.txt}

echo "🗂️  Gerando lista com label, CAN e FORM a partir dos XMLs..."
echo "Arquivo|Label|CAN|FORM" > "$SAIDA"

for file in "$PASTA"/*.xml; do
  nome_arquivo=$(basename "$file")

  # Extrai <label>
  label=$(grep -oP '(?<=<label>).*?(?=</label>)' "$file")

  # Inicializa variáveis
  can=""
  form=""

  # Extrai os blocos de <values> e lê <field> e <value> agrupadamente
  awk '
    BEGIN { field=""; value=""; in_block=0 }
    /<values>/ { in_block=1; next }
    /<\/values>/ {
      in_block=0
      if (field == "CAN")  can = value
      if (field == "FORM") form = value
      field=""; value=""
      next
    }
    in_block && /<field>/ {
      match($0, /<field>(.*)<\/field>/, a)
      field = a[1]
      next
    }
    in_block && /<value/ {
      gsub(/.*<value[^>]*>/, "", $0)
      gsub(/<\/value>.*/, "", $0)
      value = $0
      next
    }
    END {
      print can "|" form
    }
  ' "$file" | while IFS="|" read -r can form; do
    echo "${nome_arquivo}|${label}|${can}|${form}" >> "$SAIDA"
  done

done

echo "✅ Lista salva em: $SAIDA"
