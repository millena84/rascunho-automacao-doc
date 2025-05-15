#!/bin/bash
set -e

# Caminhos fixos
DATA_DIR="./data"
TMP_DIR="./tmp"
CONFIG_DIR="./config"
IDMAP="$TMP_DIR/idmap.txt"

# Lista de destinos
DESTINOS=("org_dev.json" "org_it.json" "org_uat.json")

# Cria pastas temporárias
mkdir -p "$TMP_DIR"
> "$IDMAP"  # limpa o mapeamento de IDs

# Função simples para extrair alias
extrair_alias() {
  grep '"alias"' "$1" | sed -E 's/.*"alias": *"([^"]+)".*/\1/'
}

# Função para importar entidade simples
importar_registros() {
  local entidade="$1"
  local org_dest="$2"
  local arq="$DATA_DIR/${entidade}.json"

  echo "Importando $entidade para $org_dest..."

  # Loop nos registros
  grep -o '{[^}]*"Id"[^}]*}' "$arq" | while read -r linha; do
    id_antigo=$(echo "$linha" | grep -o '"Id":"[^"]*' | cut -d':' -f2 | tr -d '"')
    corpo=$(echo "$linha" | sed 's/"Id":"[^"]*",//g')

    new_id=$(echo "$corpo" | sf data create record --target-org "$org_dest" --sobject-type "$entidade" --values-json --json | grep -o '"id":"[^"]*' | cut -d':' -f2 | tr -d '"')

    echo "$id_antigo=$new_id" >> "$IDMAP"
  done
}

# Função para buscar novo ID
buscar_novo_id() {
  grep "^$1=" "$IDMAP" | cut -d'=' -f2
}

# Processa cada destino
for cfg in "${DESTINOS[@]}"; do
  ORG_DEST=$(extrair_alias "$CONFIG_DIR/$cfg")
  echo ">>> Importando para $ORG_DEST"

  importar_registros "01_canal" "$ORG_DEST"
  importar_registros "02_formato" "$ORG_DEST"

  echo "Importando 03_vinc_canal_formato..."
  cat "$DATA_DIR/03_vinc_canal_formato.json" | grep -o '{[^}]*"Canal__c"[^}]*}' | while read -r linha; do
    old_canal=$(echo "$linha" | grep -o '"Canal__c":"[^"]*' | cut -d':' -f2 | tr -d '"')
    old_formato=$(echo "$linha" | grep -o '"Formato__c":"[^"]*' | cut -d':' -f2 | tr -d '"')

    new_canal=$(buscar_novo_id "$old_canal")
    new_formato=$(buscar_novo_id "$old_formato")

    corpo=$(echo "$linha" | sed 's/"Id":"[^"]*",//g' | sed "s/\"Canal__c\":\"$old_canal\"/\"Canal__c\":\"$new_canal\"/" | sed "s/\"Formato__c\":\"$old_formato\"/\"Formato__c\":\"$new_formato\"/")

    sf data create record --target-org "$ORG_DEST" --sobject-type "Vinculo_Canal_Formato__c" --values-json "$corpo" --json > /dev/null
  done
done

echo "Importações finalizadas com sucesso."
