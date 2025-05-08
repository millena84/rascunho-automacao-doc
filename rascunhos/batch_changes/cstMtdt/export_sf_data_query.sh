#!/bin/bash
set -e

# ============================================================================
# Script de Exportação de Dados Salesforce para CSV
# Exporta Accounts e Contacts em arquivos separados no formato .csv
# Autor: millena84
# ============================================================================

if [ -z "$1" ]; then
  echo "Uso: $0 <alias-da-org>"
  exit 1
fi

ORG_ALIAS=$1
EXPORT_DIR="data/export"

# Cria diretório se não existir
mkdir -p "$EXPORT_DIR"

# Exporta Accounts para CSV
echo "📤 Exportando Accounts para CSV..."
sf data query \
  --target-org "$ORG_ALIAS" \
  --query "SELECT Id, Name, Industry FROM Account LIMIT 100" \
  --result-format csv > "$EXPORT_DIR/accounts.csv"

# Exporta Contacts para CSV (de contas exportadas)
echo "📤 Exportando Contacts para CSV..."
sf data query \
  --target-org "$ORG_ALIAS" \
  --query "SELECT Id, FirstName, LastName, Email, AccountId FROM Contact WHERE AccountId != null LIMIT 500" \
  --result-format csv > "$EXPORT_DIR/contacts.csv"

echo "✅ Arquivos exportados para: $EXPORT_DIR"


# Converte resultado tabular para CSV
echo "📄 Convertendo resultado tabulado em CSV..."
grep -v '^[+│\-]' "$RAW_FILE" \
  | awk -F '│' 'NF >= 3 { print $2 "," $3 }' \
  | sed 's/^ *//;s/ *$//' > "$OUTPUT_CSV"

echo "✅ Dados exportados e convertidos com sucesso: $OUTPUT_CSV"
