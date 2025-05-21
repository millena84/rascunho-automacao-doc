#!/bin/bash

================================================================

Script: 20_pre_retrieve_criar_package_xml.sh

Objetivo: Gerar um package.xml baseado nos arquivos CSVs de tipos

de metadados informados no JSON de configuração

================================================================

CONFIG_FILE="/c/Users/mille/projetosSf/_configUtil.json"  # POSIX CONFIG_FILE_WIN=$(cygpath -w "$CONFIG_FILE") PASTA_CSV="./1_metadados" DATAHORA=$(date "+%Y%m%d-%H%M%S") ARQUIVO_XML_FINAL="./21_packageForRetrieve.xml" ARQUIVO_XML_VERSIONADO="./_retrieves/${DATAHORA}_21_packageForRetrieve.xml"

function info { echo -e "\033[1;34m[INFO]\033[0m $1" } function success { echo -e "\033[1;32m[SUCCESS]\033[0m $1" } function error { echo -e "\033[1;31m[ERROR]\033[0m $1" }

echo -e "\033[1;33m------------------------------------------------------------\033[0m" echo -e "  📦  INICIANDO ESTRUTURAÇÃO PACKAGE.XML PARA RETRIEVE" echo -e "  🔁  SERÁ A REFERÊNCIA DO PROCESSO DE CUSTOMMETADATA" echo -e "  🔍  INÍCIO EXECUÇÃO: $(date '+%d/%m/%Y - %H:%M:%S')" echo -e "\033[1;33m------------------------------------------------------------\033[0m"

API_VERSION="58.0" mkdir -p ./_retrieves

=== Início do package.xml ===

echo '<?xml version="1.0" encoding="UTF-8"?>' > "$ARQUIVO_XML_FINAL" echo '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' >> "$ARQUIVO_XML_FINAL"

=== Itera sobre os tipos do JSON (agora em infoEspecificaProcessos.retrieve[0].infoRetrieveCustom) ===

COMPONENTES=$(node -e " try { const cfg = require('$CONFIG_FILE_WIN'); const lista = cfg.infoEspecificaProcessos?.retrieve?.[0]?.infoRetrieveCustom || []; console.log(lista.map(c => c.tipoComponente).join(' ')); } catch (e) { console.error('❌ Erro ao extrair tipos do JSON:', e.message); process.exit(1); } ")

IFS=' ' read -ra TIPOS <<< "$COMPONENTES"

for tipo in "${TIPOS[@]}"; do tipoLower=$(echo "$tipo" | tr '[:upper:]' '[:lower:]') csv_path="$PASTA_CSV/Extracao${tipoLower}.csv"

if [[ -f "$csv_path" ]]; then info "⏰  HORÁRIO (passo exec): $(date '+%d/%m/%Y - %H:%M:%S')" info "📂  Incluindo tipo: $tipo" info "📄  Arquivo: $(basename "$csv_path")"

echo "  <types>" >> "$ARQUIVO_XML_FINAL"
while IFS= read -r linha || [[ -n "$linha" ]]; do
  [[ -z "$linha" ]] && continue
  echo "    <members>$linha</members>" >> "$ARQUIVO_XML_FINAL"
done < "$csv_path"
echo "    <name>$tipo</name>" >> "$ARQUIVO_XML_FINAL"
echo "  </types>" >> "$ARQUIVO_XML_FINAL"

else echo "⚠️  Tipo ${tipo} não encontrado em $PASTA_CSV. Pulando." fi

done

=== Fecha XML ===

echo "  <version>${API_VERSION}</version>" >> "$ARQUIVO_XML_FINAL" echo "</Package>" >> "$ARQUIVO_XML_FINAL"

cp "$ARQUIVO_XML_FINAL" "$ARQUIVO_XML_VERSIONADO"

echo "" success "✅  package.xml gerado com sucesso: $ARQUIVO_XML_FINAL" success "📁  FIM EXECUÇÃO: $(date '+%d/%m/%Y - %H:%M:%S')"

