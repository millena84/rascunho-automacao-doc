#!/bin/bash
set -euo pipefail

LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

falha() {
  echo ""
  echo "--------------------------------------------"
  echo "ERRO: Falha no processo: $processo"
  echo "Responsabilidade: $descricao_processo"
  echo "Veja o log em: $logfile"
  echo "Encerrando o processamento."
  echo "--------------------------------------------"
  echo ""
  exit 1
}

trap falha ERR

echo "Iniciando processamento de Custom Metadata..."

processo="Validação de inputs iniciais"
descricao_processo="Verifica se os arquivos e parâmetros necessários estão presentes e corretos"
logfile="$LOG_DIR/01_validar_inputs.log"
./scripts/devel/validar_inputs.sh 2>&1 | tee "$logfile"

processo="Geração de diferenças"
descricao_processo="Compara os arquivos atuais com os novos para gerar os diffs de Custom Metadata"
logfile="$LOG_DIR/02_gerar_diff.log"
./scripts/devel/gerar_diff_custom_metadata.py 2>&1 | tee "$logfile"

processo="Atualização dos arquivos XML"
descricao_processo="Atualiza os arquivos Custom Metadata XML em lote com base nas diferenças identificadas"
logfile="$LOG_DIR/03_atualizar_xml.log"
./scripts/devel/atualizar_custom_metadata.sh 2>&1 | tee "$logfile"

processo="Validação final das alterações"
descricao_processo="Garante que os arquivos XML alterados estão consistentes com o esperado"
logfile="$LOG_DIR/04_validar_final.log"
./scripts/devel/validar_atualizacao.py 2>&1 | tee "$logfile"

echo ""
echo "✅ Todos os processos foram concluídos com sucesso!"
echo "🗂️  Logs disponíveis em: $LOG_DIR"
