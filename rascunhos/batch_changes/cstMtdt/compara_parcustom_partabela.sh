#!/bin/bash

CSV_XML="csv_xml.csv"          # Ex: gerado da leitura dos XMLs
CSV_TABELA="csv_base.csv"      # Ex: vindo do Salesforce
CSV_SAIDA="saida_comparada.csv"

echo "🔍 Comparando CSV dos XMLs com CSV da tabela de referência..."
echo "Arquivo|Label|CAN_XML|FORM_XML|CAN_TABELA|FORM_TABELA|Novo" > "$CSV_SAIDA"

# Função para comparar "parecido"
semelhante() {
  a=$(echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
  b=$(echo "$2" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
  [[ "$a" == *"$b"* || "$b" == *"$a"* ]]
}

tail -n +2 "$CSV_XML" | while IFS="|" read -r ARQUIVO LABEL CAN_XML FORM_XML; do
  encontrou=0

  tail -n +2 "$CSV_TABELA" | while IFS=";" read -r CAN_TABELA FORM_TABELA; do
    if [[ "$CAN_XML" == "$CAN_TABELA" && "$FORM_XML" == "$FORM_TABELA" ]]; then
      # iguais? não grava
      encontrou=1
      break
    fi

    # parecidos?
    if semelhante "$CAN_XML" "$CAN_TABELA" && semelhante "$FORM_XML" "$FORM_TABELA"; then
      echo ""
      echo "🔎 Possível correspondência encontrada:"
      echo "Arquivo:        $ARQUIVO"
      echo "Label:          $LABEL"
      echo "CAN_XML:        $CAN_XML"
      echo "CAN_TABELA:     $CAN_TABELA"
      echo "FORM_XML:       $FORM_XML"
      echo "FORM_TABELA:    $FORM_TABELA"
      echo ""

      echo -n "❓ Deseja gravar esse registro como novo? (s/n): "
      read resposta

      if [[ "$resposta" == "s" || "$resposta" == "S" ]]; then
        echo "$ARQUIVO|$LABEL|$CAN_XML|$FORM_XML|$CAN_TABELA|$FORM_TABELA|sim" >> "$CSV_SAIDA"
      fi
    fi
  done

done

echo ""
echo "✅ Comparação finalizada. Resultados salvos em: $CSV_SAIDA"
