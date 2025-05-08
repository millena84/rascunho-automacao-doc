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

# Exporta Accounts
echo "📤 Exportando Accounts para CSV..."
sf data query \
  --query "SELECT Id, Name, Industry FROM Account LIMIT 5" \
  --target-org "$ORG_ALIAS" \
  --result-format csv \
  --output-file "$EXPORT_DIR/accounts.csv"

# Exporta Contacts associados
echo "📤 Exportando Contacts para CSV..."
sf data query \
  --query "SELECT Id, FirstName, LastName, Email, AccountId FROM Contact WHERE AccountId IN (SELECT Id FROM Account LIMIT 5)" \
  --target-org "$ORG_ALIAS" \
  --result-format csv \
  --output-file "$EXPORT_DIR/contacts.csv"

# Finalização
echo "✅ Dados exportados com sucesso em: $EXPORT_DIR"
