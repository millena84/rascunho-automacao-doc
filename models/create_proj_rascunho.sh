#!/bin/bash
set -e

# ============================================================================ 
# Nome:        _create_proj_scratch_org.sh 
# Descrição:   Cria estrutura padrão de projeto Salesforce, conecta DevHub, 
#              cria Scratch Org, opcionalmente faz retrieve e importa dados, 
#              e sobe estrutura inicial para o Git. 
# Autor:       millena84 
# Versão:      10.0.0 
# ============================================================================

function info {
  echo -e "\033[1;34m[INFO]\033[0m $1"
}
function success {
  echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}
function error {
  echo -e "\033[1;31m[ERROR]\033[0m $1"
}

CONFIG_FILE="_config_init.json"
if [ ! -f "$CONFIG_FILE" ]; then
  error "Arquivo $CONFIG_FILE não encontrado!"
  exit 1
fi

BASE_PATH="$(cd "$(dirname "$0")" && pwd)"

get_json_value() {
  node -e "console.log(require('./$CONFIG_FILE').$1)"
}

# Captura das configurações
orgAlias=$(get_json_value orgAlias)
scratchOrgAlias=$(get_json_value scratchOrgAlias)
devhubAlias=$(get_json_value devhubAlias)
defaultBranchGit=$(get_json_value defaultBranchGit)
manifestPath=$(get_json_value manifestPath)
scratchDefPath=$(get_json_value scratchDefPath)
urlGitProjectPush=$(get_json_value urlGitProjectPush)
localProjectPath=$(get_json_value localProjectPath | sed 's|\\|/|g')

echo -e "\n\033[1;33m═══════════════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;33m🏁 INICIANDO PROCESSO DE CRIAÇÃO AUTOMATIZADA SALESFORCE\033[0m"
echo -e "\033[1;33m═══════════════════════════════════════════════════════════════\033[0m\n"

info " => 📂  Checando configurações de diretório..."
current_path=$(pwd -W 2>/dev/null || pwd)
current_path=$(echo "$current_path" | sed 's|\\|/|g')
if [ -z "$current_path" ]; then
  error -e "\033[1;31m[❌]  Não foi possível determinar o diretório atual. Script não pode ser executado.\033[0m"
  exit 1
fi

if [ "$current_path" != "$localProjectPath" ]; then
  echo "[⚠️ AVISO] O diretório atual é diferente do caminho esperado no JSON."
  echo "          Diretório esperado: $localProjectPath"
  echo "          Diretório atual:    $current_path"
  echo ""
  read -p " => ⚠️ Deseja continuar mesmo assim? (s/n): " choice
  if [ "$choice" != "s" ]; then
    echo -e "\033[1;31m[❌] Execução cancelada pelo usuário.\033[0m"
    exit 1
  fi
fi

info " => 🏗️  Criando projeto Salesforce em: $localProjectPath..."
sf project generate --name "$orgAlias" --template standard --output-dir "$localProjectPath"
cd "$localProjectPath/$orgAlias" || exit

info " => 🛠️  Substituindo arquivos com modelos personalizados..."
for file in "model_sfdx-project.json" "model_project-scratch-def.json" "model-package.xml" ".gitattributes"; do
  if [ ! -f "$BASE_PATH/_init_project/$file" ]; then
    error "Arquivo $BASE_PATH/_init_project/$file não encontrado!"
    exit 1
  fi
done
cp "$BASE_PATH/_init_project/model_sfdx-project.json" "sfdx-project.json"
cp "$BASE_PATH/_init_project/model_project-scratch-def.json" "$scratchDefPath"
mkdir -p "$(dirname "$manifestPath")"
cp "$BASE_PATH/_init_project/model-package.xml" "$manifestPath"
cp "$BASE_PATH/_init_project/.gitattributes" .

info " => 🖥️  Autorizando DevHub..."
sf org login web --alias "$devhubAlias" --set-default-dev-hub

info " => 🛠️  Criando Scratch Org..."
sf config set org-capitalize-record-types=true

sf org create scratch --definition-file "$scratchDefPath" --set-default --duration-days 15 --alias "$scratchOrgAlias" 

read -p " => ⚙️  Deseja fazer retrieve dos metadados (y/n)? " doRetrieve
if [[ "$doRetrieve" == "y" ]]; then
  sf project retrieve start --manifest "$manifestPath"
fi

read -p " => 🎲  Deseja importar dados (y/n)? " doImport
if [[ "$doImport" == "y" ]]; then
  info " => 🎲  Importando dados..."
  sf data import tree --plan data/data-plan.json
fi

info " => 🔧  Inicializando Git..."
git init
# 
if git remote | grep -q origin; then
  git remote set-url origin "$urlGitProjectPush"
else
  git remote add origin "$urlGitProjectPush"
fi

info " => 🌿  Criando e subindo branch de estrutura inicial..."
git checkout -b "$defaultBranchGit"
git add .
git commit -m "chore(init): definição da estrutura inicial do projeto"
git push -u origin "$defaultBranchGit"

info " => 🔄  Sincronizando com branch main remoto (forçando merge se necessário)..."
git checkout main || git checkout -b main

# por este bloco para evitar o erro "fatal: refusing to merge unrelated histories"
if git ls-remote --heads origin main | grep -q 'refs/heads/main'; then
  git pull origin main --allow-unrelated-histories || true
  git merge "$defaultBranchGit"
else
  echo "[INFO]  => 🚨 Nenhum histórico anterior encontrado no branch remoto main. Pulando merge."
fi
git merge "$defaultBranchGit"
git push origin main
git branch -d "$defaultBranchGit" || true

info " => 🚀  Abrindo Scratch Org..."
orgUrl=$(sf org open --target-org "$scratchOrgAlias" --url-only)

if command -v explorer.exe > /dev/null; then
  set +H
  explorer.exe "$orgUrl"
  set -H
elif command -v xdg-open > /dev/null; then
  xdg-open "$orgUrl"
else
  echo "  => ⚠️  Não foi possível abrir automaticamente a Scratch Org."
  echo " => ➡️  Acesse manualmente no navegador: $orgUrl"
fi

success " => 🎉 Projeto criado, Scratch Org configurada e Git atualizado com sucesso!"
