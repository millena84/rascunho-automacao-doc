#!/bin/bash
set -e

# Configurações
ORIGEM=$(jq -r '.alias' ./config/org_origem.json)
QUERY_DIR="./queries"
DATA_DIR="./data"
mkdir -p "$DATA_DIR"

# Exporta dados de acordo com a ordem dos arquivos
for query_file in $(ls "$QUERY_DIR" | sort); do
  nome=$(basename "$query_file" _soql.txt)
  output="$DATA_DIR/${nome}.json"
  soql=$(cat "$QUERY_DIR/$query_file")

  echo "Exportando: $nome"
  sf data query --target-org "$ORIGEM" --query "$soql" --result-format json > "$output"
done

echo "Exportação concluída com sucesso."
