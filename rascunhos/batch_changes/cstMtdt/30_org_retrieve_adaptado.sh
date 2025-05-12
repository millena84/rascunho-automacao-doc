#!/bin/bash

CONFIG_FILE="./11_extract_org_metadata.json"
# DEST_DIR="force-app/main/default"

# Verifica se o arquivo de configuração existe
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Arquivo $CONFIG_FILE não encontrado!"
  exit 1
fi

# Diretório do package.xml
DEST_DIR_ARQ_RETRIEVE=$(node -e "
  try {
    const cfg = require('$CONFIG_FILE');
    if (!cfg.diretorioPackageXmlRetrieve) throw new Error('diretorioPackageXmlRetrieve ausente.');
    console.log(cfg.diretorioPackageXmlRetrieve);
  } catch (e) {
    console.error('❌ Erro ao ler diretorioPackageXmlRetrieve:', e.message);
    process.exit(1);
  }
")

PACKAGE_XML="$DEST_DIR_ARQ_RETRIEVE/21_package_retrieve.xml"

# Diretório base do projeto
DEST_DIR_PROJECTSF=$(node -e "
  try {
    const cfg = require('$CONFIG_FILE');
    if (!cfg.diretorioArqSfdxProject) throw new Error('diretorioArqSfdxProject ausente.');
    console.log(cfg.diretorioArqSfdxProject);
  } catch (e) {
    console.error('❌ Erro ao ler diretorioArqSfdxProject:', e.message);
    process.exit(1);
  }
")

# Org principal
DEST_RETR_DIR=$(node -e "
  try {
    const cfg = require('$CONFIG_FILE');
    if (!cfg.orgAliasProjeto) throw new Error('orgAliasProjeto ausente.');
    console.log(cfg.orgAliasProjeto);
  } catch (e) {
    console.error('❌ Erro ao ler orgAliasProjeto:', e.message);
    process.exit(1);
  }
")

# Alias da org para retrieve (fallback usa o alias principal)
ORG_ALIAS=$(node -e "
  try {
    const cfg = require('$CONFIG_FILE');
    if (!cfg.orgAliasProjeto) throw new Error('orgAliasProjeto ausente.');
    console.log(cfg.orgAliasProjeto);
  } catch (e) {
    console.error('❌ Erro ao ler orgAliasProjeto:', e.message);
    process.exit(1);
  }
")

ORG_ALIAS_RETRIEVE=$(node -e "
  try {
    const cfg = require('$CONFIG_FILE');
    if (!cfg.orgAliasRetrieve) throw new Error('orgAliasRetrieve ausente.');
    console.log(cfg.orgAliasRetrieve);
  } catch (e) {
    console.log('$ORG_ALIAS'); // fallback
  }
")

# Pergunta se o usuário deseja salvar na pasta do projeto
echo ""
read -r -p "Deseja fazer retrieve para a pasta do projeto atual? (s/n) : " RESP

if [[ "$RESP" =~ ^[sS]$ ]]; then
  echo "📂 Retrieve será salvo em: $DEST_DIR_PROJECTSF"
  echo "📄 Usando como referência o arquivo: $PACKAGE_XML"
  
  sf project retrieve start --manifest "$PACKAGE_XML" \
    --target-org "$ORG_ALIAS_RETRIEVE" \
    --target-metadata-dir "$DEST_DIR_PROJECTSF"

  echo "✅ Retrieve finalizado na pasta do projeto: $DEST_DIR_PROJECTSF"
else
  # Retrieve como estrutura isolada (.zip)
  METADATA_DIR="metadata_retrieve_temp"
  RETRIEVE_NAME="retrieve_${ORG_ALIAS_RETRIEVE}_$(date +'%Y%m%d-%H%M%S').zip"
  ZIP="$RETRIEVE_NAME"

  sf project retrieve start --manifest "$PACKAGE_XML" \
    --target-org "$ORG_ALIAS_RETRIEVE" \
    --target-metadata-dir "$METADATA_DIR"

  if [ -f "$METADATA_DIR/unpackaged.zip" ]; then
    mv "$METADATA_DIR/unpackaged.zip" "$ZIP"
    echo "📦 Retrieve zip salvo: $ZIP"
    unzip -q "$ZIP" -d "retrieved_unpacked"
    echo "✅ Arquivos descompactados para retrieved_unpacked/"
  else
    echo "⚠️ Nenhum arquivo .zip encontrado. Verifique erros no retrieve."
  fi
fi
