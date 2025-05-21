#!/bin/bash

# Script: 10

# Substitui o antigo 11_config_processo_custom.json pelo _configUtil.json
ARQUIVO_CONFIG="/c/Users/mille/projetosSf/_configUtil.json"  # Caminho completo POSIX
ARQUIVO_CONFIG_WIN=$(cygpath -w "$ARQUIVO_CONFIG")
DATAHORA=$(date +"%Y%m%d_%H%M%S")
PASTA_SAIDA="./1_metadados"

function info {
  echo -e "\033[1;34m[INFO]\033[0m $1"
}
function success {
  echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}
function error {
  echo -e "\033[1;31m[ERROR]\033[0m $1"
}

echo -e "\033[1;33m-------------------------------------------\033[0m"
echo -e "\033[1;33m🚀 INICIANDO EXTRACAO DE METADADOS\033[0m"
echo -e "\033[1;33m📦 DA ORGANIZACAO COMO REFERENCIA\033[0m"
echo -e "\033[1;33m-------------------------------------------\033[0m"
echo -e "\033[1;33m🕒 INICIO EXECUCAO: $(date '+%d/%m/%Y - %H:%M:%S')\033[0m"
echo ""

mkdir -p "$PASTA_SAIDA"

if [[ ! -f "$ARQUIVO_CONFIG" ]]; then
  error "❌ Arquivo $ARQUIVO_CONFIG não encontrado!"
  exit 1
fi

# Extrai alias da org usada para retrieve
ORG_ALIAS=$(node -e "
  try {
    const cfg = require('$ARQUIVO_CONFIG_WIN');
    const orgRef = cfg.infoEspecificaProcessos?.retrieve?.[0]?.orgRef;
    if (!orgRef) throw new Error('orgRef ausente.');
    console.log(orgRef);
  } catch (e) {
    console.error('❌ Erro ao ler orgRef:', e.message);
    process.exit(1);
  }
")
info "🔑 Usando alias da org: $ORG_ALIAS"
echo ""

# Extrai os componentes
COMPONENTES=$(node -e "
  try {
    const cfg = require('$ARQUIVO_CONFIG_WIN');
    const comps = cfg.infoEspecificaProcessos?.retrieve?.[0]?.infoRetrieveCustom;
    if (!Array.isArray(comps)) throw new Error('Campo infoRetrieveCustom ausente ou inválido.');
    console.log(comps.map(c => JSON.stringify(c)).join('\n'));
  } catch (e) {
    console.error('❌ Erro ao processar JSON:', e.message);
    process.exit(1);
  }
")

IFS=$'\n' read -rd '' -a COMPONENTES_ARRAY <<<"$COMPONENTES"

for compJson in "${COMPONENTES_ARRAY[@]}"; do
  tipo=$(node -e "console.log(JSON.parse(process.argv[1]).tipoComponente)" "$compJson")
  filtros=$(node -e "
    try {
      const comp = JSON.parse(process.argv[1]);
      const f = comp.filtros || [];
      console.log(f.join('|'));
    } catch (e) {
      console.error('❌ Erro ao processar JSON:', e.message);
    }
  " "$compJson")

  info "⚙️  Processando tipo de componente: $tipo"
  info "🎯 Filtros aplicados: ${filtros:-<nenhum>}"
  info "🔍 Executando: sf org list metadata --metadata-type $tipo"
  echo ""

  json_result=$(sf org list metadata --metadata-type "$tipo" --target-org "$ORG_ALIAS" --json 2>&1)

  if ! echo "$json_result" | grep -q '"result"'; then
    error "❌ Erro: saída inesperada para '$tipo'."
    echo "$json_result" | head -n 5
    error "🕒 FIM EXECUÇÃO: $(date '+%d/%m/%Y - %H:%M:%S')"
    continue
  fi

  fullnames=$(echo "$json_result" | node -e "
    let input = '';
    process.stdin.on('data', d => input += d);
    process.stdin.on('end', () => {
      try {
        const j = JSON.parse(input);
        const nomes = j.result?.map(x => x.fullName) || [];
        console.log(nomes.join('\n'));
      } catch (e) {
        console.error('❌ Erro ao processar JSON:', e.message);
      }
    });
  ")

  arquivo_saida="$PASTA_SAIDA/${DATAHORA}_Extracao_${tipo,,}.csv"

  if [[ -n "$filtros" ]]; then
    echo "$fullnames" | grep -E "$filtros" | sort > "$arquivo_saida"
  else
    echo "$fullnames" | sort > "$arquivo_saida"
  fi

  success "✅ Arquivo salvo: $arquivo_saida"
  echo ""
done

echo ""
success "🎉 Finalizado! ✅ Todos os metadados exportados com sucesso para a pasta $PASTA_SAIDA."
