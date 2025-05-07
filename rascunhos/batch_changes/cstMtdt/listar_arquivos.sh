#!/bin/bash

PASTA=${1:-.}
SAIDA=${2:-lista_com_labels.txt}

echo "🗂️  Gerando lista com label, CAN e FORM a partir dos XMLs..."
echo "Arquivo|Label|CAN|FORM" > "$SAIDA"

for file in "$PASTA"/*.xml; do
  nome_arquivo=$(basename "$file")

  # Extrai label
  label=$(grep -oP '(?<=<label>).*?(?=</label>)' "$file")

  # Extrai CAN
  can=$(awk '
    BEGIN {found=0}
    /<field>CAN<\/field>/ {found=1; next}
    found && /<value/ {
      gsub(/.*<value[^>]*>/, "", $0)
      gsub(/<\/value>.*/, "", $0)
      print $0
      exit
    }
  ' "$file")

  # Extrai FORM
  form=$(awk '
    BEGIN {found=0}
    /<field>FORM<\/field>/ {found=1; next}
    found && /<value/ {
      gsub(/.*<value[^>]*>/, "", $0)
      gsub(/<\/value>.*/, "", $0)
      print $0
      exit
    }
  ' "$file")

  echo "${nome_arquivo}|${label}|${can}|${form}" >> "$SAIDA"
done

echo "✅ Lista salva em: $SAIDA"
