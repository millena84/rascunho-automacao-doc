#!/bin/bash
set -e

TEMPLATE="BaseCustomMetadata.xml"
CSV="DadosCustomMetadata.csv"
SAIDA="saida_xml_csv"

mkdir -p "$SAIDA"

# Remove a primeira linha (cabeçalho) com `tail -n +2`
tail -n +2 "$CSV" | while IFS=";" read -r ARQUIVO APINAME LABEL CANAL FORMATO NOVO; do
  # Gera label combinada
  LABEL_FULL="$CANAL - $FORMATO"

  # Substituição dos marcadores
  sed \
    -e "s/{{LABEL_FULL}}/$LABEL_FULL/g" \
    -e "s/{{DOMINIO_CANAL}}/$CANAL/g" \
    -e "s/{{DOMINIO_FORMATO}}/$FORMATO/g" \
    -e "s/{{LABEL_TELA}}/$LABEL/g" \
    "$TEMPLATE" > "$SAIDA/$ARQUIVO"

  echo "✅ Gerado: $SAIDA/$ARQUIVO"
done
