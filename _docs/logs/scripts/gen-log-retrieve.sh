#!/bin/bash

# Script Mimi para gerar log simples pós-retrieve

DIR_FORCE="force-app/main/default/"
DIR_LOG="_docs/_updt-sand-dev-aliasOrg/"
mkdir -p "$DIR_LOG"

ARQUIVO_LOG_JSON="$DIR_LOG/alterations_log.json"
ARQUIVO_LOG_MD="$DIR_LOG/alterations_log.md"
PACKAGE_XML="manifest/package.xml"

echo "Deseja salvar o package.xml atual? (s/n)"
read COPIAR_PACKAGE

if [ "$COPIAR_PACKAGE" = "s" ] || [ "$COPIAR_PACKAGE" = "S" ]; then
  if [ -f "$PACKAGE_XML" ]; then
    cp "$PACKAGE_XML" "$DIR_LOG/package_$(date "+%Y%m%d_%H%M").xml"
    echo "Cópia do package.xml realizada!"
  else
    echo "Arquivo package.xml não encontrado."
  fi
fi

DATA_ATUAL=$(date "+%d/%m/%Y %H:%M")

echo "Procurando arquivos alterados..."
ARQUIVOS_MODIFICADOS=$(find "$DIR_FORCE" -type f \( -iname "*.cls" -o -iname "*.object-meta.xml" -o -iname "*.trigger" -o -iname "*.flow-meta.xml" -o -iname "*.validationRule-meta.xml" \))

if [ -z "$ARQUIVOS_MODIFICADOS" ]; then
  echo "Nenhum arquivo detectado. Abortando."
  exit 1
fi

echo ""
echo "Arquivos encontrados:"
echo "$ARQUIVOS_MODIFICADOS"
echo ""

echo "Digite o comentário sobre as alterações:"
read COMENTARIO

echo "Digite seu RACF ou Nome:"
read RESPONSAVEL

# Prepara para salvar o JSON
if [ ! -f "$ARQUIVO_LOG_JSON" ]; then
  echo "[]" > "$ARQUIVO_LOG_JSON"
fi

# Monta lista de arquivos para JSON
LISTA_COMPONENTES=$(echo "$ARQUIVOS_MODIFICADOS" | sed '/^$/d' | sed 's/"/\\"/g' | awk '{printf "\"%s\",", $0}' | sed 's/,$//')

ENTRADA_JSON="{\"dataHora\":\"$DATA_ATUAL\",\"responsavel\":\"$RESPONSAVEL\",\"comentario\":\"$COMENTARIO\",\"componentes\":[${LISTA_COMPONENTES}]}"

# Atualiza JSON
jq ". += [${ENTRADA_JSON}]" "$ARQUIVO_LOG_JSON" > "$ARQUIVO_LOG_JSON.tmp" && mv "$ARQUIVO_LOG_JSON.tmp" "$ARQUIVO_LOG_JSON"

# Atualiza arquivo .md
{
echo "## Log de Alterações"
echo ""
echo "| Data/Hora | Responsável | Comentário | Componentes |"
echo "|:----------|:------------|:-----------|:------------|"
jq -r '.[] | "| \(.dataHora) | \(.responsavel) | \(.comentario) | \(.componentes | join("<br>")) |"' "$ARQUIVO_LOG_JSON"
} > "$ARQUIVO_LOG_MD"

echo ""
echo "✅ Log gerado com sucesso!"
