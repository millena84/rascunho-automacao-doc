
#!/bin/bash

CONFIG_FILE="./11_extract_org_metadata.json"
PACKAGE_XML="./21_package_retrieve.xml"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ Arquivo $CONFIG_FILE não encontrado!"
  exit 1
fi

ORG_ALIAS=$(node -e "
  try {
    const cfg = require('$CONFIG_FILE');
    if (!cfg.orgAlias) throw new Error('orgAlias ausente.');
    console.log(cfg.orgAlias);
  } catch (e) {
    console.error('❌ Erro ao ler orgAlias:', e.message);
    process.exit(1);
  }
")

ORG_ALIAS_RETRIEVE=$(node -e "
  try {
    const cfg = require('$CONFIG_FILE');
    if (!cfg.orgAliasRetrieve) throw new Error('orgAliasRetrieve ausente.');
    console.log(cfg.orgAliasRetrieve);
  } catch (e) {
    console.log('$ORG_ALIAS'); // fallback: usar o mesmo alias da org se não definido
  }
")

read -p 'Deseja fazer retrieve para a pasta do projeto atual? (s/n) ' RESP

if [[ "$RESP" =~ ^[Ss]$ ]]; then
  # Retrieve dentro do projeto
  DEST_DIR="force-app/main/default"
  if [[ "$ORG_ALIAS" != "$ORG_ALIAS_RETRIEVE" ]]; then
    DEST_DIR="${DEST_DIR}_$ORG_ALIAS_RETRIEVE"
    mkdir -p "$DEST_DIR"
  fi
  echo "📦 Retrieve será salvo em: $DEST_DIR"
  sf project retrieve start --manifest "$PACKAGE_XML" --target-org "$ORG_ALIAS_RETRIEVE" --target-metadata-dir "$DEST_DIR"
  echo "✅ Retrieve finalizado na pasta do projeto: $DEST_DIR"
else
  # Retrieve para fora (estrutura isolada .zip)
  METADATA_DIR="metadata_retrieve_temp"
  RETRIEVE_NAME="retrieve_$ORG_ALIAS_RETRIEVE_$(date +"%Y%m%d-%H%M%S").zip"
  ZIP="$RETRIEVE_NAME"
  sf project retrieve start --manifest "$PACKAGE_XML" --target-org "$ORG_ALIAS_RETRIEVE" --target-metadata-dir "$METADATA_DIR"
  if [[ -f "$METADATA_DIR/unpackaged.zip" ]]; then
    mv "$METADATA_DIR/unpackaged.zip" "$ZIP"
    echo "📦 Retrieve zip salvo: $ZIP"
    unzip -q "$ZIP" -d "retrieved_unpacked"
    echo "✅ Arquivos descompactados para retrieved_unpacked/"
  else
    echo "⚠️ Nenhum arquivo .zip encontrado. Verifique erros no retrieve."
  fi
fi
