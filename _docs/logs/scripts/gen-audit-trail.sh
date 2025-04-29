#!/bin/bash

# Script para processar o CSV de Setup Audit Trail baixado manualmente
# Gera arquivos .md e .json de resumo
# Mimi Version 💙

# 1. Configurações
ARQUIVO_CSV="AuditTrail.csv"  # Nome do arquivo CSV baixado
DIR_LOG="_docs/_audit-trails/"
ARQUIVO_LOG_MD="$DIR_LOG/audit_trail_log.md"
ARQUIVO_LOG_JSON="$DIR_LOG/audit_trail_log.json"

# 2. Verifica se o diretório de log existe; se não, cria
mkdir -p "$DIR_LOG"

# 3. Verifica se o arquivo CSV existe
if [ ! -f "$ARQUIVO_CSV" ]; then
    echo "❌ Arquivo $ARQUIVO_CSV não encontrado!"
    echo "Por favor, baixe o arquivo CSV no Setup Audit Trail e coloque-o aqui."
    exit 1
fi

# 4. Lê o CSV ignorando cabeçalho
echo "Processando Audit Trail..."

LINHAS=$(tail -n +2 "$ARQUIVO_CSV")

# 5. Inicializa o JSON
echo "[]" > "$ARQUIVO_LOG_JSON"

# 6. Processa linha a linha
while IFS=',' read -r Data Usuario Ação Detalhes; do
    # Remove aspas extras
    Data=$(echo "$Data" | sed 's/"//g')
    Usuario=$(echo "$Usuario" | sed 's/"//g')
    Ação=$(echo "$Ação" | sed 's/"//g')
    Detalhes=$(echo "$Detalhes" | sed 's/"//g')

    # Atualiza JSON
    jq --arg data "$Data" --arg usuario "$Usuario" --arg acao "$Ação" --arg detalhes "$Detalhes" \
    '. += [{"data": $data, "usuario": $usuario, "acao": $acao, "detalhes": $detalhes}]' \
    "$ARQUIVO_LOG_JSON" > "$ARQUIVO_LOG_JSON.tmp" && mv "$ARQUIVO_LOG_JSON.tmp" "$ARQUIVO_LOG_JSON"

done <<< "$LINHAS"

# 7. Gera o arquivo .md
{
echo "## Setup Audit Trail Extraído"
echo ""
echo "| Data | Usuário | Ação | Detalhes |"
echo "|:-----|:--------|:-----|:---------|"

jq -r '.[] | "| \(.data) | \(.usuario) | \(.acao) | \(.detalhes) |"' "$ARQUIVO_LOG_JSON"

} > "$ARQUIVO_LOG_MD"

# 8. Exibe resumo
echo ""
echo "✅ Audit Trail processado!"
echo "Resultados:"
echo "- $ARQUIVO_LOG_JSON"
echo "- $ARQUIVO_LOG_MD"
