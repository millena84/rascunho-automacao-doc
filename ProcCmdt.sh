#!/bin/bash

set -euo pipefail

LOG_DIR="./_logs"
mkdir -p "$LOG_DIR"

# Funções visuais
function cabec_lote      { echo -e "\033[1;33m[ℹ️ ] $1\033[0m"; }
function cabec_passo     { echo -e "\033[1;39m[➡️ ] $1\033[0m"; }
function info            { echo -e "\033[1;34m[INF ⚠️  ] - $1\033[0m"; }
function success         { echo -e "\033[1;32m[SUC ✅ ] - $1\033[0m"; }
function error           { echo -e "\033[1;31m[ERR ❌ ] - $1\033[0m"; }

# Em caso de falha
falha() {
  echo ""
  error "❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌"
  error "❌ ERRO: Falha no processo: $processo"
  error "❌ Responsabilidade: $descricao_processo"
  error "❌ Veja o log em: $logfile"
  error "🔵 FIM EXECUÇÃO: $(date '+%d/%m/%Y - %H:%M:%S')"
  echo ""
  exit 1
}
trap falha ERR

# Cabeçalho inicial
cabec_lote "🔧 --- INICIANDO - ALTERAÇÃO - CMDT EM LOTE ---"
cabec_lote "📜 Esta shell fará todas as chamadas necessárias na sequência."
cabec_lote "🕘 INICIO EXECUÇÃO: $(date '+%d/%m/%Y - %H:%M:%S')"
echo ""

# Função para ler valor do JSON baseado no índice do passo
get_json_value() {
  local chave="$1"
  local index="$2"
  grep -A 10 "\"passo\": \"$index\"" "$jsonFile" | grep "\"$chave\"" | cut -d':' -f2- | sed 's/[",]//g' | xargs
}

# Caminho do JSON
jsonFile="procCmdt_0_Processa_lote.json"

# Detectar quantidade de passos
totalPassos=$(grep -c '"passo":' "$jsonFile")

# Loop pelos passos
for ((i=1; i<=totalPassos; i++)); do
  passo="$i"
  processo=$(get_json_value "processo" "$i")
  descricao_processo=$(get_json_value "descricao_processo" "$i")
  nome_programa=$(get_json_value "nome_programa" "$i")
  tipo_execucao=$(get_json_value "tipo_execucao" "$i")
  DATAHORA=$(date +"%Y%m%d_%H%M%S")
  logfile="$LOG_DIR/log_p${passo}_${nome_programa}_$DATAHORA"

  cabec_lote ""
  cabec_lote "🟥 Chamando processo: $processo"
  cabec_lote "🟥 Função processo..: $descricao_processo"
  cabec_lote "🟥 Log processo.....: $logfile"

  if [[ "$tipo_execucao" == "shellScript" ]]; then
    bash "./$nome_programa" 2>&1 | tee "$logfile"
  elif [[ "$tipo_execucao" == "Python" ]]; then
    PYTHONIOENCODING=utf-8 python3 "./$nome_programa" 2>&1 | iconv -f utf-8 -t utf-8//IGNORE | tee "$logfile"
  else
    error "Tipo de execução desconhecido: $tipo_execucao"
    exit 1
  fi

  cabec_lote ""
  cabec_lote "🟣 FIM DO PASSO $passo - $descricao_processo"
  cabec_lote "🕘 $(date '+%d/%m/%Y - %H:%M:%S')"
  cabec_lote "--------------------------------------------------"
  echo ""
done

cabec_lote "✅ Todos os processos foram concluídos com sucesso!"
cabec_lote "📂 Logs disponíveis em: $LOG_DIR"
cabec_lote "🕘 FIM EXECUÇÃO: $(date '+%d/%m/%Y - %H:%M:%S')"
