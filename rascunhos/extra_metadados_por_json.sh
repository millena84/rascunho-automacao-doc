#!/bin/bash

CONFIG_FILE="./config_metadata.json"
DATAHORA=$(date +"%Y%m%d_%H%M%S")

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ Arquivo $CONFIG_FILE não encontrado!"
  exit 1
fi

# Lê o alias da org do JSON via Node
ORG_ALIAS=$(node -e "console.log(require('$CONFIG_FILE').orgAlias)")

# Lê os componentes do JSON via Node, um por um
COMPONENTES=$(node -e "
  const cfg = require('$CONFIG_FILE');
  console.log(cfg.componentes.map(c => JSON.stringify(c)).join('||'));
")

IFS='||' read -ra COMPONENTES_ARRAY <<< "$COMPONENTES"

for compJson in "${COMPONENTES_ARRAY[@]}"; do
  # Lê tipoComponente e filtros
  tipo=$(node -e "console.log(JSON.parse('$compJson').tipoComponente)")
  filtros=$(node -e "
    const f = JSON.parse('$compJson').filtros;
    if (!f) return;
    console.log(f.join('||'))
  ")

  echo ""
  echo "📦 Exportando: $tipo..."

  # Executa o comando base e pega os fullNames
  json_result=$(sf org list metadata-type "$tipo" --target-org "$ORG_ALIAS" --json)
  fullnames=$(echo "$json_result" | node -e "let input = ''; process.stdin.on('data', d => input += d); process.stdin.on('end', () => {
    const j = JSON.parse(input);
    const nomes = j.result?.metadataObjects?.map(x => x.fullName) || [];
    console.log(nomes.join('\n'));
  })")

  # Aplica filtro (se houver)
  arquivo_saida="${tipo,,}_${DATAHORA}.csv"
  if [[ -n "$filtros" ]]; then
    echo "$fullnames" | grep -E "$(echo "$filtros" | sed 's/||/|/g')" | sort > "$arquivo_saida"
  else
    echo "$fullnames" | sort > "$arquivo_saida"
  fi

  echo "✅ Arquivo gerado: $arquivo_saida"
done
