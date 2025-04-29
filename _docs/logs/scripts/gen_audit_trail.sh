#!/bin/bash

# Script Mimi para processar CSV de Audit Trail manual

ARQUIVO_CSV="AuditTrail.csv"
DIR_LOG="_docs/_audit-trails/"
mkdir -p "$DIR_LOG"

ARQUIVO_LOG_JSON="$DIR_LOG/audit_trail_log.json"
ARQUIVO_LOG_MD="$DIR_LOG/audit_trail_log.md"

if [ ! -f "$ARQUIVO_CSV" ]; then
  echo "Arquivo AuditTrail.csv não encontrado!"
  echo "Coloque o arquivo na mesma pasta do script."
  exit 1
fi

echo "Processando AuditTrail.csv..."

tail -n +2 "$ARQUIVO_CSV" | while IFS=',' read -r Data Usuario Acao Detalhes; do
  Data=$(echo "$Data" | sed 's/"//g')
  Usuario=$(echo "$Usuario" | sed 's/"//g')
  Acao=$(echo "$Acao" | sed 's/"//g')
  Detalhes=$(echo "$Detalhes" | sed 's/"//g')

  if [ ! -f "$ARQUIVO_LOG_JSON" ]; then
    echo "[]" > "$ARQUIVO_LOG_JSON"
  fi

  ENTRADA_JSON="{\"data\":\"$Data\",\"usuario\":\"$Usuario\",\"acao\":\"$Acao\",\"detalhes\":\"$Detalhes\"}"
  jq ". += [${ENTRADA_JSON}]" "$ARQUIVO_LOG_JSON" > "$ARQUIVO_LOG_JSON.tmp" && mv "$ARQUIVO_LOG_JSON.tmp" "$ARQUIVO_LOG_JSON"
done

# Gera .md
{
echo "## Setup Audit Trail Extraído"
echo ""
echo "| Data | Usuário | Ação | Detalhes |"
echo "|:-----|:--------|:-----|:---------|"
jq -r '.[] | "| \(.data) | \(.usuario) | \(.acao) | \(.detalhes) |"' "$ARQUIVO_LOG_JSON"
} > "$ARQUIVO_LOG_MD"

echo ""
echo "✅ Audit Trail processado!"
