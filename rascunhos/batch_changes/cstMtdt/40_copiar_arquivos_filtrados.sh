
#!/bin/bash

CONFIG_FILE="./11_extract_org_metadata.json"

# 🔍 Valida JSON e extrai campos
BASE_PATH=$(node -e "
  try {
    const cfg = require('$CONFIG_FILE');
    if (!cfg.retrievedBasePath) throw new Error('retrievedBasePath ausente');
    console.log(cfg.retrievedBasePath);
  } catch (e) {
    console.error('Erro ao ler retrievedBasePath:', e.message);
    process.exit(1);
  }
")

FILTRO=$(node -e "
  try {
    const cfg = require('$CONFIG_FILE');
    if (!cfg.filtroNomeArquivo) throw new Error('filtroNomeArquivo ausente');
    console.log(cfg.filtroNomeArquivo);
  } catch (e) {
    console.error('Erro ao ler filtroNomeArquivo:', e.message);
    process.exit(1);
  }
")

DESTINO="./_copiados_${FILTRO}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$DESTINO"

echo "📁 Base: $BASE_PATH"
echo "🔎 Filtro: *$FILTRO*"
echo "📂 Destino: $DESTINO"
echo ""

# Copia arquivos que batem com o filtro
mapfile -t arquivos < <(find "$BASE_PATH" -type f -name "*$FILTRO*")

if [[ ${#arquivos[@]} -eq 0 ]]; then
  echo "⚠️ Nenhum arquivo encontrado com o filtro '$FILTRO'"
  exit 0
fi

for arq in "${arquivos[@]}"; do
  # Cria estrutura de diretório no destino
  pasta_dest=$(dirname "$arq" | sed "s|$BASE_PATH||")
  mkdir -p "$DESTINO/$pasta_dest"
  cp "$arq" "$DESTINO/$pasta_dest/"
  echo "✅ Copiado: $arq -> $DESTINO/$pasta_dest/"
done

echo ""
echo "✅ Finalizado! Total copiado: ${#arquivos[@]}"
