#!/bin/bash

# Script para gerar log de alterações pós-retrieve Salesforce
# Estrutura padrão usada: force-app/main/default/
# Logs: _docs/_updt-sand-dev-aliasOrg/

# Configurações
DIR_FORCE="force-app/main/default/"
DIR_LOG="_docs/_updt-sand-dev-aliasOrg/"
ARQUIVO_LOG_JSON="$DIR_LOG/alterations_log.json"
ARQUIVO_LOG_MD="$DIR_LOG/alterations_log.md"
PACKAGE_XML="manifest/package.xml"

# 1. Verifica se o diretório de log existe; se não, cria
mkdir -p "$DIR_LOG"

# 2. Pergunta se deseja salvar cópia do package.xml
echo "Deseja fazer uma cópia do package.xml atual antes do retrieve? (s/n)"
read COPIAR_PACKAGE

if [ "$COPIAR_PACKAGE" == "s" ] || [ "$COPIAR_PACKAGE" == "S" ]; then
    if [ -f "$PACKAGE_XML" ]; then
        cp "$PACKAGE_XML" "$DIR_LOG/package_$(date "+%Y%m%d_%H%M").xml"
        echo "Cópia do package.xml realizada!"
    else
        echo "❌ package.xml não encontrado em $PACKAGE_XML."
    fi
fi

# 3. Pega a data/hora atual
DATA_ATUAL=$(date "+%d/%m/%Y %H:%M")

# 4. Lista arquivos relevantes no force-app/main/default/
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

# 5. Pergunta comentário da alteração
echo "Digite um comentário sobre essa alteração (ex: 'Criação campo CPF e ajuste de flow'):"
read COMENTARIO

# 6. Pergunta quem é o responsável (RACF ou Nome)
echo "Digite seu RACF ou Nome de identificação:"
read RESPONSAVEL

# 7. Prepara o JSON da nova entrada
JSON_NOVA_ENTRADA=$(jq -n \
  --arg dataHora "$DATA_ATUAL" \
  --arg responsavel "$RESPONSAVEL" \
  --arg comentario "$COMENTARIO" \
  --argjson componentes "$(echo "$ARQUIVOS_MODIFICADOS" | jq -R -s -c 'split("\n")[:-1]')" \
  '{dataHora: $dataHora, responsavel: $responsavel, comentario: $comentario, componentes: $componentes}')

# 8. Atualiza o arquivo JSON
if [ ! -f "$ARQUIVO_LOG_JSON" ]; then
    echo "[]" > "$ARQUIVO_LOG_JSON"
fi

jq ". += [$JSON_NOVA_ENTRADA]" "$ARQUIVO_LOG_JSON" > "$ARQUIVO_LOG_JSON.tmp" && mv "$ARQUIVO_LOG_JSON.tmp" "$ARQUIVO_LOG_JSON"

# 9. Atualiza o arquivo .md para humanos
{
echo "## Log de Alterações"
echo ""
echo "| Data/Hora | Responsável | Comentário | Componentes |"
echo "|:----------|:------------|:-----------|:------------|"

jq -r '.[] | "| \(.dataHora) | \(.responsavel) | \(.comentario) | \(.componentes | join("<br>")) |"' "$ARQUIVO_LOG_JSON"

} > "$ARQUIVO_LOG_MD"

# 10. Exibe resumo
echo ""
echo "✅ Log atualizado!"
echo "Local: $ARQUIVO_LOG_JSON e $ARQUIVO_LOG_MD"
echo "Componentes registrados: $(echo "$ARQUIVOS_MODIFICADOS" | wc -l)"
