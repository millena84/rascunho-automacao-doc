#!/bin/bash

CONFIG_FILE="./10_extract_org_metadata.json"
PASTA_CSV="./metadados"
ARQUIVO_XML="./package_retrieve.xml"
API_VERSION="58.0"

echo "🧱 Gerando package.xml com base nos arquivos em $PASTA_CSV..."

# Início do package.xml
echo '<?xml version="1.0" encoding="UTF-8"?>' > "$ARQUIVO_XML"
echo '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' >> "$ARQUIVO_XML"

# Itera sobre os tipos do JSON
COMPONENTES=$(node -e "
  const cfg = require('$CONFIG_FILE');
  console.log(cfg.componentes.map(c => c.tipoComponente).join('|'));
")

IFS='|' read -ra TIPOS <<< "$COMPONENTES"

for tipo in "${TIPOS[@]}"; do
  tipoLower=$(echo "$tipo" | tr '[:upper:]' '[:lower:]')
  csv_path="$PASTA_CSV/Extracao_${tipoLower}_*.csv"
  arquivo_csv=$(ls $csv_path 2>/dev/null | head -n1)

  if [[ -f "$arquivo_csv" ]]; then
    echo "📦 Incluindo tipo: $tipo"
    echo "  ↳ Arquivo: $(basename "$arquivo_csv")"

    echo "  <types>" >> "$ARQUIVO_XML"
    while IFS= read -r linha || [[ -n "$linha" ]]; do
      [[ -z "$linha" ]] && continue
      echo "    <members>${linha}</members>" >> "$ARQUIVO_XML"
    done < "$arquivo_csv"
    echo "    <name>${tipo}</name>" >> "$ARQUIVO_XML"
    echo "  </types>" >> "$ARQUIVO_XML"
  else
    echo "⚠️  Tipo ${tipo} não encontrado em $PASTA_CSV. Pulando."
  fi
done

# Fecha XML
echo "  <version>${API_VERSION}</version>" >> "$ARQUIVO_XML"
echo "</Package>" >> "$ARQUIVO_XML"

echo ""
echo "✅ package.xml gerado com sucesso: $ARQUIVO_XML"
