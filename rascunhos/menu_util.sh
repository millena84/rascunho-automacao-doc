#!/bin/bash

### === CONFIGURAÇÃO ===
ARQUIVO_CONFIG="_configUtil.json"

# Valida se arquivo existe
if [ ! -f "$ARQUIVO_CONFIG" ]; then
  echo "❌ Arquivo de configuração $ARQUIVO_CONFIG não encontrado."
  exit 1
fi

# Função para ler valores do JSON
get_json_value() {
  node -e "console.log(JSON.parse(require('fs').readFileSync('$ARQUIVO_CONFIG'))$1)"
}

# Captura diretório raiz do projeto (base VSCode)
DIR_PROJETO=$(get_json_value "['infoVscode'][0].dirPosixRepoVscode")

# Função para executar scripts em suas respectivas pastas
executar_script_em_pasta() {
  local pasta_relativa="$1"
  local script_nome="$2"

  local caminho_script="$DIR_PROJETO/$pasta_relativa/$script_nome"

  if [ ! -f "$caminho_script" ]; then
    echo "❌ Script não encontrado em: $caminho_script"
    exit 1
  fi

  echo "➡️ Acessando pasta: $DIR_PROJETO/$pasta_relativa"
  cd "$DIR_PROJETO/$pasta_relativa" || exit 1
  echo "🚀 Executando: $script_nome"
  chmod +x "$script_nome"
  ./$script_nome
}

### === MENU INTERATIVO ===
while true; do
  echo "\n🛠️  CENTRAL DE UTILITÁRIOS PARA PROJETOS SF"
  echo "------------------------------------------"
  echo "1) Criar ambiente"
  echo "2) Fazer retrieve"
  echo "3) Avaliar Cmdt de Can x For (DE)"
  echo "4) Avaliar Cmdt de Neg x Can (CM)"
  echo "5) Fazer deploy (somente dev e teste)"
  echo "6) Fazer extração de dados"
  echo "7) Documentação automática"
  echo "0) Sair"
  echo "------------------------------------------"
  read -rp "Escolha uma opção: " opcao

  case $opcao in
    1)
      executar_script_em_pasta "__01-criacaoAmbiente" "10_criar_projeto_sf.sh"
      ;;
    2)
      executar_script_em_pasta "__02-retrieve" "20_retrieve_proj_sf.sh"
      ;;
    3)
      executar_script_em_pasta "__03-avaliacaoCanFor" "30_avaliar_can_for.sh"
      ;;
    4)
      executar_script_em_pasta "__04-avaliacaoNegCan" "40_avaliar_neg_can.sh"
      ;;
    5)
      executar_script_em_pasta "__05-deploy" "50_deploy_dev_teste.sh"
      ;;
    6)
      executar_script_em_pasta "__06-extracaoDados" "60_extrair_dados.sh"
      ;;
    7)
      executar_script_em_pasta "__07-docAutomatica" "70_gerar_docs_autom.sh"
      ;;
    0)
      echo "👋 Saindo."
      break
      ;;
    *)
      echo "❗ Opção inválida. Tente novamente."
      ;;
  esac

done
