#!/bin/bash
set -e

# Configurações
DESTINOS=( "org_dev.json" "org_it.json" "org_uat.json" )
DATA_DIR="./data"
TMP_DIR="./tmp"
IDMAP="$TMP_DIR/id_maps.json"
mkdir -p "$TMP_DIR"
echo "{}" > "$IDMAP"

# Função para importar registros de uma entidade simples
import_entidade() {
  local sobject="$1"
  local dest="$2"
  local file="$DATA_DIR/${sobject}.json"

  echo "Importando $sobject para $dest"
  cat "$file" | jq -c '.result.records[]' | while read -r record; do
    old_id=$(echo "$record" | jq -r '.Id')
    body=$(echo "$record" | jq 'del(.attributes, .Id)')
    
    new_id=$(echo "$body" | sf data create record --target-org "$dest" --sobject-type "$sobject" --values-json --json | jq -r '.result.id')
    jq --arg old "$old_id" --arg new "$new_id" '.[$old] = $new' "$IDMAP" > "$IDMAP.tmp" && mv "$IDMAP.tmp" "$IDMAP"
  done
}

# Importa para cada org destino
for DEST_JSON in "${DESTINOS[@]}"; do
  DEST=$(jq -r '.alias' "./config/$DEST_JSON")
  echo ">>> Importando para $DEST"

  import_entidade "01_canal" "$DEST"
  import_entidade "02_formato" "$DEST"

  # Importa vínculo com substituição de IDs
  echo "Importando vínculos..."
  cat "$DATA_DIR/03_vinc_canal_formato.json" | jq -c '.result.records[]' | while read -r record; do
    old_canal=$(echo "$record" | jq -r '.Canal__c')
    old_formato=$(echo "$record" | jq -r '.Formato__c')
    new_canal=$(jq -r --arg o "$old_canal" '.[$o]' "$IDMAP")
    new_formato=$(jq -r --arg o "$old_formato" '.[$o]' "$IDMAP")

    body=$(echo "$record" | jq --arg nc "$new_canal" --arg nf "$new_formato" 'del(.attributes, .Id) | .Canal__c = $nc | .Formato__c = $nf')
    sf data create record --target-org "$DEST" --sobject-type "Vinculo_Canal_Formato__c" --values-json "$body" --json > /dev/null
  done
done

echo "Importações finalizadas com sucesso."
