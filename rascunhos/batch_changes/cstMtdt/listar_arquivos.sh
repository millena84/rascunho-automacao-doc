#!/bin/bash

PASTA=${1:-.}
SAIDA=${2:-lista_com_labels.txt}

echo "🗂️  Gerando lista com label, CAN e FORM a partir dos XMLs..."
echo "Arquivo|Label|CAN|FORM" > "$SAIDA"

for file in "$PASTA"/*.xml; do
  nome_arquivo=$(basename "$file")

  # Extrai label (deve estar sempre em uma linha só)
  label=$(grep -oP '(?<=<label>).*?(?=</label>)' "$file")

  # Extrai CAN
  can=$(awk '
    BEGIN {in_field=0}
    /<field>[[:space:]]*CAN[[:space:]]*<\/field>/ {in_field=1; next}
    in_field && /<value/ {
      if (match($0, /<value[^>]*>([^<]*)<\/value>/, arr)) {
        print arr[1]
        exit
      }
    }
  ' "$file")

  # Extrai FORM
  form=$(awk '
    BEGIN {in_field=0}
    /<field>[[:space:]]*FORM[[:space:]]*<\/field>/ {in_field=1; next}
    in_field && /<value/ {
      if (match($0, /<value[^>]*>([^<]*)<\/value>/, arr)) {
        print arr[1]
        exit
      }
    }
  ' "$file")

  echo "${nome_arquivo}|${label}|${can}|${form}" >> "$SAIDA"
done

echo "✅ Lista salva em: $SAIDA"
