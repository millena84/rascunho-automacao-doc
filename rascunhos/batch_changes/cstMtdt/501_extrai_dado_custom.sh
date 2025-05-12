#!/bin/bash
# Script para extrair campos WW2_Canal__c e WW2_Formato__c com suporte multilinha e salvar como CSV com BOM + CRLF

set -e

PASTA="${1:-./2_entrada_xml}"
SAIDA="${2:-./1_metadados/_DadoCustomMetadata_ref.csv}"

function info    { echo -e "\033[1;34m[INFO]\033[0m $1"; }
function success { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
function error   { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

info "🔎 EXTRAINDO PARAMETRIZACOES DOS CUSTOM METADATA"
info "🕓 INICIO EXECUCAO: $(date '+%d/%m/%Y - %H:%M:%S')"

# Gera cabeçalho com BOM e CRLF (usando \r\n no printf)
printf '\xEF\xBB\xBFNomeArquivoXml,Label,CanalXml,FormatoXml\r\n' > "$SAIDA"

for file in "$PASTA"/*.xml; do
  nome_arquivo=$(basename "$file")
  label=$(grep -oP '(?<=<label>).*?(?=</label>)' "$file" || echo "")

  can=""
  form=""
  field=""
  value=""
  in_block=0

  while IFS= read -r linha; do
    [[ $linha =~ "<values>" ]] && in_block=1 && continue
    [[ $linha =~ "</values>" ]] && in_block=0 && continue
    [[ $in_block -eq 0 ]] && continue

    if [[ $linha =~ "<field>" ]]; then
      field=$(echo "$linha" | sed -E 's/.*<field>([^<]+)<\/field>.*/\1/')
    fi

    if [[ $linha =~ "<value" ]]; then
      value=$(echo "$linha" | sed -E 's/.*<value[^>]*>([^<]*)<\/value>.*/\1/')
      if [[ $field == "WW2_Canal__c" ]]; then
        can="$value"
      elif [[ $field == "WW2_Formato__c" ]]; then
        form="$value"
      fi
      field=""
      value=""
    fi
  done < "$file"

  # Adiciona \r\n no final da linha manualmente para forçar CRLF
  printf '%s,%s,%s,%s\r\n' "$nome_arquivo" "$label" "$can" "$form" >> "$SAIDA"
done

success "✅ Lista salva em: $SAIDA (com CRLF e BOM)"
success "🕓 FIM EXECUCAO: $(date '+%d/%m/%Y - %H:%M:%S')"
