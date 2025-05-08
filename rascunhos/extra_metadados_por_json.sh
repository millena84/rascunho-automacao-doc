#!/bin/bash

CONFIG_FILE="./10_extract_org_metadata.json"
DATAHORA=$(date +"%Y%m%d_%H%M%S")
PASTA_SAIDA="./metadados"

mkdir -p "$PASTA_SAIDA"

# 🎯 Verifica se o JSON existe
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ Arquivo $CONFIG_FILE não encontrado!"
  exit 1
fi

# 🔹 Extrai alias da org
ORG_ALIAS=$(node -e "
  try {
    const cfg = require('$CONFIG_FILE');
    if (!cfg.orgAlias) throw new Error('orgAlias ausente.');
    console.log(cfg.orgAlias);
  } catch (e) {
    console.error('❌ Erro ao ler orgAlias:', e.message);
    process.exit(1);
  }
")

echo "📤 Usando alias da org: $ORG_ALIAS"
echo ""

# 🔹 Extrai os componentes
COMPONENTES=$(node -e "
  try {
    const cfg = require('$CONFIG_FILE');
    if (!Array.isArray(cfg.componentes)) throw new Error('Campo \"componentes\" ausente ou inválido.');
    console.log(cfg.componentes.map(c => JSON.stringify(c)).join('||'));
  } catch (e) {
    console.error('❌ Erro ao processar JSON:', e.message);
    process.exit(1);
  }
")

IFS='||' read -ra COMPONENTES_ARRAY <<< "$COMPONENTES"

for compJson in "${COMPONENTES_ARRAY[@]}"; do
  tipo=$(node -e "console.log(JSON.parse(process.argv[1]).tipoComponente)" "$compJson")
  filtros=$(node -e "
    try {
      const comp = JSON.parse(process.argv[1]);
      const f = comp.filtros || [];
      console.log(f.join('|'));
    } catch (e) {
      console.log('');
    }
  " "$compJson")

  echo "🔹 Processando tipo de componente: $tipo"
  echo "🔍 Filtros aplicados: ${filtros:-<nenhum>}"
  echo "⏳ Executando: sf org list metadata --metadata-type $tipo"

  # Executa comando correto (listagem dos metadados do tipo)
  json_result=$(sf org list metadata --metadata-type "$tipo" --target-org "$ORG_ALIAS" --json 2>&1)

  # Verifica se retorno contém JSON
  if ! echo "$json_result" | grep -q '"result"'; then
    echo "❌ Erro: saída inesperada para '$tipo'."
    echo "$json_result" | head -n 5
    echo "--------------------------------------------"
    continue
  fi

  # Extrai os fullNames
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

  # Define nome do arquivo
  arquivo_saida="$PASTA_SAIDA/Extracao_${tipo,,}_${DATAHORA}.csv"

  # Aplica filtro se existir
  if [[ -n "$filtros" ]]; then
    echo "$fullnames" | grep -E "$filtros" | sort > "$arquivo_saida"
  else
    echo "$fullnames" | sort > "$arquivo_saida"
  fi

  echo "✅ Arquivo salvo: $arquivo_saida"
  echo "--------------------------------------------"
done

echo ""
echo "🏁 Finalizado! Todos os metadados exportados com sucesso para a pasta $PASTA_SAIDA."
