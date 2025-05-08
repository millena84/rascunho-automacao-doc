#!/bin/bash

FILTRO="$1"
DATAHORA=$(date +"%Y%m%d_%H%M%S")
ARQUIVO="objetos_customizados_${DATAHORA}.csv"

# Executa o comando e filtra se necessário
if [[ -z "$FILTRO" ]]; then
  sf org list metadata-type CustomObject --target-org "$SF_TARGET_ORG" --json \
    | jq -r '.result.metadataObjects[].fullName' \
    | sort > "$ARQUIVO"
else
  sf org list metadata-type CustomObject --target-org "$SF_TARGET_ORG" --json \
    | jq -r '.result.metadataObjects[].fullName' \
    | grep "$FILTRO" | sort > "$ARQUIVO"
fi

echo "✅ Lista de objetos exportada para: $ARQUIVO"
