#!/bin/bash
set -euo pipefail  # -u: erro em variáveis não definidas, -o pipefail: falha se parte do pipeline falhar

# Função para erro customizado
falha() {
  echo ""
  echo "--------------------------------------------"
  echo "ERRO: Falha no processo: $processo"
  echo "Responsabilidade: $descricao_processo"
  echo "Encerrando o processamento."
  echo "--------------------------------------------"
  echo ""
  exit 1
}

# Tratamento de erro
trap falha ERR

echo "Iniciando processamento de Custom Metadata..."

processo="Validação de inputs iniciais"
descricao_processo="Verifica se os arquivos e parâmetros necessários estão presentes e corretos"
./scripts/devel/validar_inputs.sh

processo="Geração de diferenças"
descricao_processo="Compara os arquivos atuais com os novos para gerar os diffs de Custom Metadata"
./scripts/devel/gerar_diff_custom_metadata.py

processo="Atualização dos arquivos XML"
descricao_processo="Atualiza os arquivos Custom Metadata XML em lote com base nas diferenças identificadas"
./scripts/devel/atualizar_custom_metadata.sh

processo="Validação final das alterações"
descricao_processo="Garante que os arquivos XML alterados estão consistentes com o esperado"
./scripts/devel/validar_atualizacao.py

echo ""
echo "Todos os processos foram concluídos com sucesso!"
