

#SCRIPT 6 - Criação de XMLs via shell usando cp + sed (Git Bash ou Linux)

#Salve como: criar_shell_sed.sh


#!/bin/bash

CSV_CAMINHO="./3_saida_csv/2_listaVinculosPrecisamCustom.csv" MODELO_XML="./5_modelo_base/CamposCanalFormato.MODELO.md-meta.xml" PASTA_DESTINO="./5_xml_novos_shell"

mkdir -p "$PASTA_DESTINO" CONTADOR=1

tail -n +2 "$CSV_CAMINHO" | while IFS=';' read -r LABEL FILHO PAI CAMPOS_TELA CANAL FORMATO OBJETO TELA

do NOME_ARQUIVO="CamposCanalFormato.${FORMATO^^}$(printf "%03d" $CONTADOR).md-meta.xml" DESTINO="$PASTA_DESTINO/$NOME_ARQUIVO" cp "$MODELO_XML" "$DESTINO"

Substituição do valor de Canal__c

sed -i 
-E "0,/<field>Canal__c<\/field>[[:space:]]<value[^>]>.*<\/value>/s//<field>Canal__c</field><value>${CANAL}</value>/" "$DESTINO"

Substituição do valor de Formato__c

sed -i 
-E "0,/<field>Formato__c<\/field>[[:space:]]<value[^>]>.*<\/value>/s//<field>Formato__c</field><value>${FORMATO}</value>/" "$DESTINO"

echo "✅ Criado via shell: $NOME_ARQUIVO" CONTADOR=$((CONTADOR + 1))

done

