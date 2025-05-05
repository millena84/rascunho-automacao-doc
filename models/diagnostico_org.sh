#!/bin/bash
set -e

# ============================================================================
# Script de Diagnóstico de Organização Salesforce
# Gera relatório com dados de limites e objetos de uma org conectada
# Autor: millena84
# ============================================================================
# Uso:
#   ./diagnostico-org.sh <alias-da-org>
# Exemplo:
#   ./diagnostico-org.sh orgDevappbuilder842024DevHub
# ============================================================================

if [ -z "$1" ]; then
  echo "Uso: $0 <alias-da-org>"
  exit 1
fi

ORG_ALIAS=$1
timestamp=$(date +%Y-%m-%d-%Hh%M)
logfile="_docs/logs/_diagnostico/diagnostico-org-${ORG_ALIAS}-${timestamp}.txt"

{
  echo "======================================================"
  echo "🔍 Diagnóstico da org Salesforce: $ORG_ALIAS"
  echo "======================================================"

  PROJECT_DIR=$(find . -type f -name "sfdx-project.json" -exec dirname {} \; | head -n 1)
  PROJECT_VSCODE_DIR=$(pwd)
  echo " 📁 Diretório do projeto Vscode: $PROJECT_VSCODE_DIR"
  echo " 📁 Diretório do projeto Salesforce: $PROJECT_VSCODE"
  echo "======================================================"

  # Info da org
  sf org display --target-org "$ORG_ALIAS"

  # Limites
  echo -e "\n------------------------------------------------------"
  echo "📊 Limites da Org"
  echo "------------------------------------------------------"
  sf limits api display --target-org "$ORG_ALIAS"

  # Objetos disponíveis
  echo -e "\n------------------------------------------------------"
  echo "📚 Objetos Disponíveis"
  echo "------------------------------------------------------"
  PROJECT_DIR=$(find . -type f -name "sfdx-project.json" -exec dirname {} \; | head -n 1)
  if [ -n "$PROJECT_DIR" ]; then
    echo "📁 Executando a partir do projeto localizado em: $PROJECT_DIR"
    (cd "$PROJECT_DIR" && sf data query -q "SELECT QualifiedApiName FROM EntityDefinition" --target-org "$ORG_ALIAS" )
  else
    echo "⚠️  Comando não executado: nenhum projeto Salesforce (sfdx-project.json) foi encontrado nesta estrutura de diretórios."
  fi

  # Arvore de diretório atual
  echo -e "\n------------------------------------------------------"
  echo "🗂️  Estrutura de diretórios do projeto atual"
  echo "------------------------------------------------------"
  find . -type d | sort

  echo -e "\n✅ Diagnóstico concluído para a org: $ORG_ALIAS"
  echo "🚀 Dica: use 'sf schema list fields --object <objeto> --target-org $ORG_ALIAS' para explorar os campos"

} | tee "$logfile"

echo ""

echo -e "\n📝 Log salvo em: $logfile"
echo "======================================================"
