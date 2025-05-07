#!/bin/bash

PASTA=${1:-.}
SAIDA=${2:-lista_com_labels.txt}

echo "🗂️  Gerando lista com label, CAN e FORM a partir dos XMLs..."
echo "Arquivo|Label|CAN|FORM" > "$SAIDA"

for file in "$PASTA"/*.xml; do
  nome_arquivo=$(basename "$file")

  label=$(grep -oP '(?<=<label>).*?(?=</label>)' "$file")

  CAN=""
  FORM=""

  # Esse awk percorre o XML e associa o último <field> com o próximo <value>
  awk '
    /<field>/ {
      if ($0 ~ /<field>CAN<\/field>/)  last="CAN";
      else if ($0 ~ /<field>FORM<\/field>/) last="FORM";
      else last="";
      next;
    }
    /<value/ && last != "" {
      gsub(/.*<value[^>]*>/, "", $0)
      gsub(/<\/value>.*/, "", $0)
      if (last == "CAN") can=$0;
      if (last == "FORM") form=$0;
      last="";
    }
    END {
      print can "|" form;
    }
  ' "$file" | while IFS="|" read -r can form; do
    echo "${nome_arquivo}|${label}|${can}|${form}" >> "$SAIDA"
  done

done

echo "✅ Lista salva em: $SAIDA"
