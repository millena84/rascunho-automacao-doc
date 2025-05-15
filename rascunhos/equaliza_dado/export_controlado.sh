#!/bin/bash
set -e

# Caminhos fixos
QUERY_DIR="./queries"
DATA_DIR="./data"
CONFIG_ORIGEM="./config/org_origem.json"

# Extrai alias do arquivo de config
ORG_ORIGEM=$(grep '"alias"' "$CONFIG_ORIGEM" | sed -E 's/.*"alias": *"([^"]+)".*/\1/')

# Cria pasta de dados
mkdir -p "$DATA_DIR"

# Exporta dados baseados nos arquivos da pasta queries
for query_file in $(ls "$QUERY_DIR" | sort); do
  nome=$(basename "$query_file" _soql.txt)
  soql=$(cat "$QUERY_DIR/$query_file")
  output="$DATA_DIR/${nome}.json"

  echo "Exportando: $nome"
  sf data query --target-org "$ORG_ORIGEM" --query "$soql" --result-format json > "$output"
done

echo "Exportação concluída."
