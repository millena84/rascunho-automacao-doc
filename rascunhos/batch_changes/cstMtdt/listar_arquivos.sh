#!/bin/bash

PASTA=${1:-.}
SAIDA=${2:-lista_com_labels.txt}

echo "🗂️  Gerando lista com label, CAN e FORM a partir dos XMLs..."
echo "Arquivo|Label|CAN|FORM" > "$SAIDA"

for file in "$PASTA"/*.xml; do
  nome_arquivo=$(basename "$file")

  # Extrai o label (linha única)
  label=$(grep -oP '<label>\K[^<]+' "$file")

  # Inicializa
  can=""
  form=""
  ultima_field=""

  # Processa linha a linha
  while IFS= read -r line; do
    # Detecta <field> e guarda temporariamente
    if [[ "$line" =~ \<field\>(.*)\</field\> ]]; then
      ultima_field="${BASH_REMATCH[1]}"
    fi

    # Detecta <value> e associa ao último field se for CAN ou FORM
    if [[ "$line" =~ \<value[^\>]*\>(.*)\</value\> ]]; then
      valor="${BASH_REMATCH[1]}"
      if [[ "$ultima_field" == "CAN" ]]; then
        can="$valor"
      elif [[ "$ultima_field" == "FORM" ]]; then
        form="$valor"
      fi
      ultima_field=""  # reseta
    fi
  done < "$file"

  echo "${nome_arquivo}|${label}|${can}|${form}" >> "$SAIDA"
done

echo "✅ Lista salva em: $SAIDA"
