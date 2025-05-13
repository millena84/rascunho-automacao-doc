#!/bin/bash
set -e

# ========================================================
# Script de Exportação de Dados Salesforce para CSV
# - Exporta vínculos Canal e Formato do Custom Metadata
# - Autor: millena84
# ========================================================

CONFIG_FILE="./11_extract_org_metadata.json"
EXPORT_DIR="./1_metadados"
RAW_FILE="$EXPORT_DIR/_saidaTerminal.txt"
OUTPUT_CSV="$EXPORT_DIR/14_VincParamCustom-CanalFormato.csv"

echo ""
echo "🔍 Iniciando exportação de vínculos Canal/Formato..."

# Verifica se o JSON existe
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ Arquivo $CONFIG_FILE não encontrado!"
  exit 1
fi

# Extrai alias da org de consulta
ORG_ALIAS_CONSULTA=$(node -e "
  try {
    const cfg = require('$CONFIG_FILE');
    if (!cfg.orgAliasRetrieve) throw new Error('orgAliasRetrieve ausente.');
    console.log(cfg.orgAliasRetrieve);
  } catch (e) {
    console.error('❌ Erro ao ler orgAliasRetrieve:', e.message);
    process.exit(1);
  }
")

# Cria diretório se não existir
mkdir -p "$EXPORT_DIR"

echo ""
echo "📦 Alias da org de consulta: $ORG_ALIAS_CONSULTA"
echo "📂 Arquivo bruto: $RAW_FILE"
echo "📄 Arquivo CSV final: $OUTPUT_CSV"
echo ""

# Executa a query sobrescrevendo
echo "🚀 Executando query na org..."
sf data query \
  --query "SELECT IUJ_Par_Canal_Contato_Lkp__r.Name, IUJ_Par_Formt_Lkp__r.Name FROM IUJ_Vinc_Can_Formt__c WHERE IUJ_Par_Formt_Lkp__r.IUJ_Precisa_Dado_Especifico__c = true ORDER BY IUJ_Par_Canal_Contato_Lkp__r.Name, IUJ_Par_Formt_Lkp__r.Name" \
  --target-org "$ORG_ALIAS_CONSULTA" > "$RAW_FILE"

echo "✅ Consulta concluída com sucesso!"
echo ""

# Converte o resultado tabular limpo para CSV puro
echo "🔧 Convertendo resultado em CSV formatado..."

{
  echo "CanalTab,FormatoTab"
  grep '│' "$RAW_FILE" \
    | grep -vE 'IUJ_PAR_|─|┌|┬|┐|├|┤|└|┴|┘|Total number of records' \
    | sed -E 's/\x1b\[[0-9;]*m//g' \
    | awk -F '│' '{
        gsub(/^[ \t]+|[ \t]+$/, "", $2);
        gsub(/^[ \t]+|[ \t]+$/, "", $3);
        print $2 "," $3;
      }'
} > "$OUTPUT_CSV"

echo ""
echo "🎉 Arquivo CSV gerado com sucesso!"
echo "📌 Local: $OUTPUT_CSV"
echo ""
