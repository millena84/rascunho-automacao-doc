#!/bin/bash
# Garante saída limpa e com BOM em CSVs com acentuação

set -e

PASTA="${1:-./2_entrada_xml}"
SAIDA="${2:-./1_metadados/_DadoCustomMetadata_ref.csv}"

function info  { echo -e "\033[1;34m[INFO]\033[0m $1"; }
function success { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
function error { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

info "📄 EXTRAINDO PARAMETRIZAÇÕES FEITAS NOS CUSTOM METADATA DE PROD"
info "🕓 INICIO EXECUCAO: $(date '+%d/%m/%Y - %H:%M:%S')"
info "📥 Gerando lista com label, CAN e FORM a partir dos XMLs..."

# Cria header com BOM UTF-8
printf '\xEF\xBB\xBFNomeArquivoXml,Label,CanalXml,FormatoXml\n' > "$SAIDA"

for file in "$PASTA"/*.xml; do
  nome_arquivo=$(basename "$file")
  label=$(grep -oP '(?<=<label>).*?(?=</label>)' "$file")

  can=""
  form=""

  awk '
    BEGIN { field=""; value=""; in_block=0; }
    /<values>/ { in_block=1; next }
    /<\/values>/ { in_block=0; next }
    in_block && /<field>/ {
      match($0, /<field>(.*)<\/field>/, a);
      field=a[1];
      next
    }
    in_block && /<value>/ {
      gsub(/.*<value[^>]*>/, "", $0);
      gsub(/<\/value>.*/, "", $0);
      value=$0;
      if (field == "Canal__") can = value;
      if (field == "Formato__") form = value;
      field=""; value="";
    }
    END {
      print can "|" form
    }
  ' "$file" | while IFS='|' read -r can form; do
    echo "${nome_arquivo},${label},${can},${form}" >> "$SAIDA"
  done
done

success "✅ Lista salva em: $SAIDA"
success "🕓 FIM EXECUCAO: $(date '+%d/%m/%Y - %H:%M:%S')"
