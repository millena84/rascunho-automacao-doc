#!/bin/bash

DIR_ENTRADA="./entrada_xml"
DIR_SAIDA="./saida_xml"
CSV_SAIDA="$DIR_SAIDA/listaCustomAlteracao.csv"

mkdir -p "$DIR_SAIDA"

echo "🔁 Atualizando XMLs mantendo a ordem original com precisão linha a linha..."

tail -n +2 "$CSV_SAIDA" | while IFS="," read -r ARQUIVO CAN_TABELA FORM_TABELA; do
  INPUT_XML="$DIR_ENTRADA/$ARQUIVO"
  OUTPUT_XML="$DIR_SAIDA/$ARQUIVO"

  if [ ! -f "$INPUT_XML" ]; then
    echo "⚠️ Arquivo não encontrado: $INPUT_XML"
    continue
  fi

  awk -v can="$CAN_TABELA" -v form="$FORM_TABELA" '
    BEGIN { skip=0 }
    /<values>/ { buffer=$0; skip=1; next }
    skip {
      buffer=buffer"\n"$0
      if (/<\/values>/) {
        if (buffer ~ /WW2_Canal__c/) {
          print "  <values>"
          print "    <field>WW2_Canal__c</field>"
          print "    <value xsi:type=\"xsd:string\">"can"</value>"
          print "  </values>"
        } else if (buffer ~ /WW2_Formato__c/) {
          print "  <values>"
          print "    <field>WW2_Formato__c</field>"
          print "    <value xsi:type=\"xsd:string\">"form"</value>"
          print "  </values>"
        } else {
          print buffer
        }
        skip=0
        next
      }
      next
    }
    { print }
  ' "$INPUT_XML" > "$OUTPUT_XML"

  echo "✅ Atualizado: $ARQUIVO"
done

echo ""
echo "🏁 Finalizado. XMLs salvos em: $DIR_SAIDA"