#!/bin/bash

CSV_XML="./_metadados/011_lista_com_labels.csv"
CSV_TABELA="./_metadados/011_VincParamCustom-CanalFormato.csv"
CSV_SAIDA="./saida_xml/listaCustomAlteracao.csv"
DIR_SAIDA="./saida_xml"

mkdir -p "$DIR_SAIDA"

echo "🔍 Comparando apenas o FORMATO (CANAL assumido como correto)..."
echo "Arquivo,CAN_TABELA,FORM_TABELA" > "$CSV_SAIDA"

semelhante() {
  a=$(echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
  b=$(echo "$2" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
  [[ "$a" == *"$b"* || "$b" == *"$a"* ]]
}

linha_atual=0
total=$(tail -n +2 "$CSV_XML" | wc -l)

# Carrega toda a tabela de referência em memória
mapfile -t tabela_ref < <(sed '1d' "$CSV_TABELA")

# Loop externo: lê cada linha do XML
while IFS="," read -r ARQUIVO LABEL CAN_XML FORM_XML; do
  ((linha_atual++))
  echo "📄 [$linha_atual/$total] Verificando: $ARQUIVO | FORM_XML: $FORM_XML"

  # Pula se linha estiver vazia
  [[ -z "$ARQUIVO" || -z "$FORM_XML" ]] && continue

  for linha_ref in "${tabela_ref[@]}"; do
    IFS="," read -r CAN_TABELA FORM_TABELA <<< "$linha_ref"

    if semelhante "$FORM_XML" "$FORM_TABELA"; then
      echo ""
      echo "🔎 Possível correspondência encontrada (formato apenas):"
      echo "Arquivo:        $ARQUIVO"
      echo "FORM_XML:       $FORM_XML"
      echo "FORM_TABELA:    $FORM_TABELA"
      echo ""

      while true; do
        echo -n "❓ Deseja gravar esse registro como novo? (s/n): "
        read -r resposta < /dev/tty
        if [[ "$resposta" == "s" || "$resposta" == "S" ]]; then
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

done < <(tail -n +2 "$CSV_XML")

echo ""
echo "✅ Comparação finalizada. Resultados salvos em: $CSV_SAIDA"
