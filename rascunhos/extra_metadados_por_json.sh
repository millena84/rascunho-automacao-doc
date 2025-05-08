#!/bin/bash

CONFIG_FILE="./config_metadata.json"
DATAHORA=$(date +"%Y%m%d_%H%M%S")

# 🎯 Verifica se o JSON existe
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ Arquivo $CONFIG_FILE não encontrado!"
  exit 1
fi

# 🔹 Extrai alias da org com node
ORG_ALIAS=$(node -e "
  try {
    console.log(require('$CONFIG_FILE').orgAlias || '');
  } catch(e) {
    console.error('❌ Erro ao ler orgAlias do JSON:', e.message);
    process.exit(1);
  }
")

if [[ -z "$ORG_ALIAS" ]]; then
  echo "❌ Alias da org não encontrado no JSON."
  exit 1
fi

echo "📤 Usando alias da org: $ORG_ALIAS"
echo ""

# 🔹 Extrai array de componentes em JSON
COMPONENTES=$(node -e "
  try {
    const cfg = require('$CONFIG_FILE');
    if (!Array.isArray(cfg.componentes)) throw new Error('Campo \"componentes\" ausente ou inválido.');
    console.log(cfg.componentes.map(c => JSON.stringify(c)).join('||'));
  } catch(e) {
    console.error('❌ Erro ao processar JSON:', e.message);
    process.exit(1);
  }
")

IFS='||' read -ra COMPONENTES_ARRAY <<< "$COMPONENTES"

for compJson in "${COMPONENTES_ARRAY[@]}"; do
  tipo=$(node -e "console.log(JSON.parse('$compJson').tipoComponente)")
  filtros=$(node -e "
    const comp = JSON.parse('$compJson');
    if (!comp.filtros || comp.filtros.length === 0) {
      console.log('');
    } else {
      console.log(comp.filtros.join('|'));
    }
  ")

  echo "🔹 Processando tipo de componente: $tipo"
  echo "🔍 Filtros aplicados: ${filtros:-<nenhum>}"

  # Executa o sf org list metadata-type
  echo "⏳ Executando: sf org list metadata-type $tipo"
  json_result=$(sf org list metadata-type "$tipo" --target-org "$ORG_ALIAS" --json 2>/dev/null)

  # Verifica se veio algo
  if [[ -z "$json_result" || "$json_result" == *"error"* ]]; then
    echo "❌ Erro ao consultar metadados do tipo $tipo. Pulando..."
    continue
  fi

  fullnames=$(echo "$json_result" | node -e "
    let input = ''; process.stdin.on('data', d => input += d);
    process.stdin.on('end', () => {
      try {
        const j = JSON.parse(input);
        const nomes = j.result?.metadataObjects?.map(x => x.fullName) || [];
        console.log(nomes.join('\n'));
      } catch (e) {
        console.error('❌ Erro ao processar JSON retornado do sf:', e.message);
      }
    });
  ")

  # Salva com ou sem filtro
  arquivo_saida="${tipo,,}_${DATAHORA}.csv"
  if [[ -n "$filtros" ]]; then
    echo "$fullnames" | grep -E "$filtros" | sort > "$arquivo_saida"
  else
    echo "$fullnames" | sort > "$arquivo_saida"
  fi

  echo "✅ Arquivo salvo: $arquivo_saida"
  echo "--------------------------------------------"
done

echo ""
echo "🏁 Finalizado! Todos os metadados exportados com sucesso."
