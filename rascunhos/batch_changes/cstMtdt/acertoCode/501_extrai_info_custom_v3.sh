#!/bin/bash
# =============================================================
# Script de extração de campos WW2_Canal__c e WW2_Formato__c
# com suporte a multilinha, saída limpa em CSV com BOM + CRLF
# Compatível com Excel, Python, BI e sistemas com acentuação
# Autor: Millena + JubileuGPT
# =============================================================

set -e

PASTA="${1:-./2_entrada_xml_test}"
SAIDA="${2:-./1_metadados/_DadoCustomMetadata_ref.csv}"

function info    { echo -e "\033[1;34m[INFO]\033[0m $1"; }
function success { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
function warn    { echo -e "\033[1;33m[WARN]\033[0m $1"; }
function error   { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

info "🔎 INICIANDO EXTRAÇÃO DE PARAMETRIZAÇÕES"
info "📂 Pasta de entrada: $PASTA"
info "📄 Arquivo de saída: $SAIDA"
info "🕓 Início: $(date '+%d/%m/%Y - %H:%M:%S')"

# Cria diretório de saída, se necessário
mkdir -p "$(dirname "$SAIDA")"

# Cabeçalho com BOM + CRLF
printf '\xEF\xBB\xBFNomeArquivoXml,Label,CanalXml,FormatoXml\r\n' > "$SAIDA"

# Loop pelos arquivos XML
for file in "$PASTA"/*.xml; do
  nome_arquivo=$(basename "$file")

  # Valida existência e legibilidade
  if [[ ! -s "$file" || ! -r "$file" ]]; then
    warn "Ignorando arquivo vazio ou sem permissão: $nome_arquivo"
    continue
  fi

  # Verifica se parece um CustomMetadata
  if ! grep -q "<CustomMetadata" "$file"; then
    warn "Ignorando arquivo que não contém CustomMetadata: $nome_arquivo"
    continue
  fi

  # Extrai label (nome legível)
  label=$(grep -oP '(?<=<label>).*?(?=</label>)' "$file" || echo "")

  can=""
  form=""
  field=""
  value=""
  in_block=0

  # Leitura linha a linha
  while IFS= read -r linha || [[ -n "$linha" ]]; do
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

  # Escreve no CSV com CRLF
  printf '%s,%s,%s,%s\r\n' "$nome_arquivo" "$label" "$can" "$form" >> "$SAIDA"
done

success "✅ Arquivo final salvo com sucesso: $SAIDA"
success "🕓 Fim: $(date '+%d/%m/%Y - %H:%M:%S')"
