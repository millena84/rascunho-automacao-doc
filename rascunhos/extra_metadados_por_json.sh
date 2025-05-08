#!/bin/bash

JSON_CONFIG="$1"
ORG_ALIAS="$2"

if [[ -z "$JSON_CONFIG" || -z "$ORG_ALIAS" ]]; then
  echo "❗ Uso: ./exportar_metadados_por_json.sh caminho/arquivo.json nomeDaOrg"
  exit 1
fi

DATAHORA=$(date +"%Y%m%d_%H%M%S")

# Itera sobre cada tipo de componente definido no JSON
jq -c '.[]' "$JSON_CONFIG" | while read -r componente; do
  TIPO=$(echo "$componente" | jq -r '.tipoComponente')
  ARQUIVO_SAIDA="${TIPO,,}_${DATAHORA}.csv"

  echo "📦 Exportando: $TIPO..."

  # Executa comando base
  sf org list metadata-type "$TIPO" --target-org "$ORG_ALIAS" --json \
    | jq -r '.result.metadataObjects[].fullName' > temp_result.txt

  # Aplica filtros, se existirem
  FILTERS=$(echo "$componente" | jq -r '.filtros[]?')
  if [[ -n "$FILTERS" ]]; then
    > "$ARQUIVO_SAIDA"
    for filtro in $FILTERS; do
      grep "$filtro" temp_result.txt >> "$ARQUIVO_SAIDA"
    done
    sort -u "$ARQUIVO_SAIDA" -o "$ARQUIVO_SAIDA"
  else
    mv temp_result.txt "$ARQUIVO_SAIDA"
  fi

  echo "✅ Arquivo gerado: $ARQUIVO_SAIDA"
done

rm -f temp_result.txt
