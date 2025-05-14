###
# SCRIPT 3 - Atualiza XML via shell (usando sed no Git Bash ou Linux)
# Salve como: atualizar_shell_sed.sh
# Torne executável com: chmod +x atualizar_shell_sed.sh
# Execute com: ./atualizar_shell_sed.sh
###

#!/bin/bash

# Diretórios ajustáveis:
CSV_CAMINHO="./3_saida_csv/1_listaCustomAlteracao.csv"
XML_ENTRADA_DIR="./2_entrada_xml"
XML_SAIDA_DIR="./4_xml_corrigido_shell"

mkdir -p "$XML_SAIDA_DIR"

# Lê o CSV linha por linha (ignorando o cabeçalho)
tail -n +2 "$CSV_CAMINHO" | while IFS=';' read -r ARQUIVO LABEL CANAL_XML FORMATO_XML CANAL_TABELA FORMATO_TABELA

do
  ORIGEM="$XML_ENTRADA_DIR/$ARQUIVO"
  DESTINO="$XML_SAIDA_DIR/$ARQUIVO"

  if [[ -f "$ORIGEM" ]]; then
    cp "$ORIGEM" "$DESTINO"

    # Substitui valor de Canal__c
    sed -i \
      -E "0,/<field>Canal__c<\\/field>[[:space:]]*<value[^>]*>.*<\\/value>/s//<field>Canal__c<\/field><value>${CANAL_TABELA}<\/value>/" "$DESTINO"

    # Substitui valor de Formato__c
    sed -i \
      -E "0,/<field>Formato__c<\\/field>[[:space:]]*<value[^>]*>.*<\\/value>/s//<field>Formato__c<\/field><value>${FORMATO_TABELA}<\/value>/" "$DESTINO"

    echo "✅ Atualizado via sed: $ARQUIVO"
  else
    echo "❌ Arquivo não encontrado: $ARQUIVO"
  fi

done
