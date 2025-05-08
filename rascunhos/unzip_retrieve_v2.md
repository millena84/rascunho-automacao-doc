#!/bin/bash

ZIP="unpackaged.zip"
PASTA_DESTINO="${ZIP%.zip}"

echo "📦 Extraindo: $ZIP → $PASTA_DESTINO/"

unzip -q "$ZIP" -d "$PASTA_DESTINO"

# Se tiver unpackaged/unpackaged/, move tudo para um nível acima
if [[ -d "$PASTA_DESTINO/unpackaged/unpackaged" ]]; then
  echo "🔧 Corrigindo estrutura aninhada dupla..."
  mv "$PASTA_DESTINO/unpackaged/unpackaged/"* "$PASTA_DESTINO/"
  rm -rf "$PASTA_DESTINO/unpackaged"
fi

# Se tiver unpackaged direto
if [[ -d "$PASTA_DESTINO/unpackaged" ]]; then
  echo "🔧 Corrigindo estrutura padrão unpackaged/"
  mv "$PASTA_DESTINO/unpackaged/"* "$PASTA_DESTINO/"
  rmdir "$PASTA_DESTINO/unpackaged" 2>/dev/null
fi

echo "✅ Extração finalizada em: $PASTA_DESTINO/"
