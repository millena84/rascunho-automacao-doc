#!/bin/bash

# Caminho do package gerado anteriormente
PACKAGE_XML="./package_retrieve.xml"

# Caminho absoluto para a raiz do projeto SF (ajuste se necessário)
PROJ_RAIZ="../../.."                     # ou use $(git rev-parse --show-toplevel)
METADATA_DIR="$PROJ_RAIZ/force-app/main/default"

# Alias da org de destino (pode ler de JSON se quiser)
ALIAS="jornadev02"

# Verificação
if [[ ! -f "$PACKAGE_XML" ]]; then
  echo "❌ package.xml não encontrado: $PACKAGE_XML"
  exit 1
fi

echo "🚀 Iniciando retrieve..."
echo "📦 package: $PACKAGE_XML"
echo "📁 destino: $METADATA_DIR"
echo "🔗 org:     $ALIAS"

# Executa retrieve de forma segura
sf project retrieve start \
  --manifest "$PACKAGE_XML" \
  --target-org "$ALIAS" \
  --target-metadata-dir "$METADATA_DIR" \
  --quiet

echo "✅ Retrieve concluído."
