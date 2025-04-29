#!/bin/bash

# Script para gerar log de alterações após um retrieve no Salesforce
# Estrutura padrão de pastas usada: force-app/main/default/
# Logs serão gravados em: _docs/_updt-sand-dev-aliasOrg/

# Configurações
DIR_FORCE="force-app/main/default/"
DIR_LOG="_docs/_updt-sand-dev-aliasOrg/"
ARQUIVO_LOG_JSON="$DIR_LOG/alterations_log.json"
ARQUIVO_LOG_MD="$DIR_LOG/alterations_log.md"

# 1. Verifica se o diretório de log existe; se não, cria
mkdir -p "$DIR_LOG"

# 2. Pega a data/hora atual
DATA_ATUAL=$(date "+%d/%m/%Y %H:%M")

# 3. Lista todos os arquivos modificados ou criados (pega tudo no force-app/main/default/)
echo "Detectando componentes alterados..."
ARQUIVOS_MODIFICADOS=$(find "$DIR_FORCE" -type f \( -name "*.cls" -o -name "*.object-meta.xml" -o -name "*.trigger" -o -name "*.flow-meta.xml" -o -name "*.validationRule-meta.xml" -o -name "*.fieldSet-meta.xml" \))

if [ -z "$ARQUIVOS_MODIFICADOS" ]; then
    echo "Nenhum arquivo relevante detectado. Abortando."
    exit 1
fi

echo ""
echo "Componentes detectados:"
echo "$ARQUIVOS_MODIFICADOS"
echo ""

# 4. Pergunta comentário da alteração
echo "Digite um comentário sobre essa alteração (ex: 'Criação campo CPF e ajuste de flow'):"
read COMENTARIO

# 5. Pergunta quem é o responsável (RACF ou Nome)
echo "Digite seu RACF ou Nome de identificação:"
read RESPONSAVEL

# 6. Prepara o JSON da nova entrada
JSON_NOVA_ENTRADA=$(jq -n \
  --arg dataHora "$DATA_ATUAL" \
  --arg responsavel "$RESPONSAVEL" \
  --arg comentario "$COMENTARIO" \
  --argjson componentes "$(echo "$ARQUIVOS_MODIFICADOS" | jq -R -s -c 'split("\n")[:-1]')" \
  '{dataHora: $dataHora, responsavel: $responsavel, comentario: $comentario, componentes: $componentes}')

# 7. Atualiza o arquivo JSON
if [ ! -f "$ARQUIVO_LOG_JSON" ]; then
    echo "[]" > "$ARQUIVO_LOG_JSON"
fi

jq ". += [$JSON_NOVA_ENTRADA]" "$ARQUIVO_LOG_JSON" > "$ARQUIVO_LOG_JSON.tmp" && mv "$ARQUIVO_LOG_JSON.tmp" "$ARQUIVO_LOG_JSON"

# 8. Atualiza ou cria o arquivo .md de log humano
{
echo "## Log de Alterações"
echo ""
echo "| Data/Hora | Responsável | Comentário | Componentes |"
echo "|:----------|:------------|:-----------|:------------|"

jq -r '.[] | "| \(.dataHora) | \(.responsavel) | \(.comentario) | \(.componentes | join("<br>")) |"' "$ARQUIVO_LOG_JSON"

} > "$ARQUIVO_LOG_MD"

# 9. Exibe resumo
echo ""
echo "✅ Log atualizado!"
echo "Local: $ARQUIVO_LOG_JSON e $ARQUIVO_LOG_MD"
echo "Componentes registrados: $(echo "$ARQUIVOS_MODIFICADOS" | wc -l)"
