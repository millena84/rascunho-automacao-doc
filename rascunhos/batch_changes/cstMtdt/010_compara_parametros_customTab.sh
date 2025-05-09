#!/bin/bash

CSV_XML="./_metadados/lista_com_labels.csv"
CSV_TABELA="./_metadados/VincParamCustom-CanalFormato.csv"
CSV_SAIDA="./saida_xml/listaCustomAlteracao.csv"
DIR_SAIDA="saida_xml"


mkdir -p "$DIR_SAIDA"

echo "🔍 Comparando CSV dos XMLs com CSV da tabela de referência..."
# echo "Arquivo|Label|CAN_XML|FORM_XML|CAN_TABELA|FORM_TABELA|Novo" > "$CSV_SAIDA"
echo "Arquivo,CAN_TABELA,FORM_TABELA" > "$CSV_SAIDA"

semelhante() {
  a=$(echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
  b=$(echo "$2" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
  [[ "$a" == *"$b"* || "$b" == *"$a"* ]]
}

# Lê o CSV linha a linha ignorando o cabeçalho
exec 3< <(tail -n +2 "$CSV_XML")
while IFS="," read -r ARQUIVO LABEL CAN_XML FORM_XML <&3; do
  encontrou=0

  exec 4< <(tail -n +2 "$CSV_TABELA")
  while IFS="," read -r CAN_TABELA FORM_TABELA <&4; do
    if [[ "$CAN_XML" == "$CAN_TABELA" && "$FORM_XML" == "$FORM_TABELA" ]]; then
      encontrou=1
      break
    fi

    if semelhante "$CAN_XML" "$CAN_TABELA" && semelhante "$FORM_XML" "$FORM_TABELA"; then
      echo ""
      echo "🔎 Possível correspondência encontrada:"
      echo "Arquivo:        $ARQUIVO"
      echo "Label:          $LABEL"
      echo "CAN_XML:        $CAN_XML"
      echo "FORM_XML:       $FORM_XML"
      echo "CAN_TABELA:     $CAN_TABELA"
      echo "FORM_TABELA:    $FORM_TABELA"
      echo ""

      while true; do
        echo -n "❓ Deseja gravar esse registro como novo? (s/n): "
        read -r resposta
        if [[ "$resposta" == "s" || "$resposta" == "S" ]]; then
          # echo "$ARQUIVO|$LABEL|$CAN_XML|$FORM_XML|$CAN_TABELA|$FORM_TABELA|sim" >> "$CSV_SAIDA"
          echo "$ARQUIVO,$CAN_TABELA,$FORM_TABELA" >> "$CSV_SAIDA"
          echo "✅ Registro salvo. Execute: ./cria_xml.sh \"$ARQUIVO\" \"$LABEL\" \"$CAN_TABELA\" \"$FORM_TABELA\""
          break
        elif [[ "$resposta" == "n" || "$resposta" == "N" ]]; then
          echo "⏭ Ignorado."
          break
        else
          echo "❌ Resposta inválida. Digite 's' ou 'n'."
        fi
      done
    fi
  done
  exec 4<&-
done
exec 3<&-

echo ""
echo "✅ Comparação finalizada. Resultados salvos em: $CSV_SAIDA"