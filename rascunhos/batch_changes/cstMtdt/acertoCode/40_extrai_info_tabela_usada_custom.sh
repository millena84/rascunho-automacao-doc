#!/bin/bash set -e

Caminhos

RAW_FILE="./1_metadados/_saidaTerminal.txt" OUTPUT_CSV="./1_metadados/_VincParCustom-CanalFormato.csv"

Garantir que os arquivos estão no formato UNIX

if command -v dos2unix &> /dev/null; then dos2unix "$RAW_FILE" 2>/dev/null || true fi

Gera CSV limpo com exatamente 3 colunas: Canal, Formato, Flag

{ echo "CanalTab,FormatoTab,FormTemDadoEspec" grep '|' "$RAW_FILE" 
| grep -Ev '^+||\s*(IUJ_PAR_CANAL_CONTATO_LKP__R|IUJ_PAR_FORMT_LKP__R)' 
| sed -E 's/\x1b
