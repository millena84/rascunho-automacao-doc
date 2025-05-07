#!/bin/bash

TEMPLATE="BaseCustomMetadata_v1.xml"
CSV="DadosCustomMetadata_v1.csv"
ENTRADA_XML="entrada_xml"
SAIDA="saida_xml_csv"

mkdir -p "$SAIDA"

echo ""
echo "📋 INÍCIO DA VERIFICAÇÃO:"
echo "--------------------------"

# Lê o CSV (pulando cabeçalho) para array de linhas
mapfile -t linhas < <(tail -n +2 "$CSV")

for linha in "${linhas[@]}"; do
  # Lê os campos da linha atual
  IFS=";" read -r ARQUIVO APINAME LABEL CANAL FORMATO NOVO <<< "$linha"
  LABEL_FULL="$CANAL - $FORMATO"
  XML_EXISTENTE="$ENTRADA_XML/$ARQUIVO"
  XML_NOVO="$SAIDA/$ARQUIVO"

  echo ""
  echo "🔎 [$ARQUIVO]"

  if [[ -f "$XML_EXISTENTE" ]]; then
    VALOR_XML_CANAL=$(grep -A1 '<field>WWx_Canal__c</field>' "$XML_EXISTENTE" | tail -n1 | sed -E 's/.*>(.*)<.*/\1/')
    VALOR_XML_FORMATO=$(grep -A1 '<field>WWx_Formato__c</field>' "$XML_EXISTENTE" | tail -n1 | sed -E 's/.*>(.*)<.*/\1/')

    printf -- "- WWx_Canal__c:   %-30s (Custom atual: %s)\n" "$CANAL" "$VALOR_XML_CANAL"
    printf -- "- WWx_Formato__c: %-30s (Custom atual: %s)\n" "$FORMATO" "$VALOR_XML_FORMATO"

    dif=0
    [[ "$CANAL" != "$VALOR_XML_CANAL" ]] && echo "⚠️  Diferença em Canal" && dif=1
    [[ "$FORMATO" != "$VALOR_XML_FORMATO" ]] && echo "⚠️  Diferença em Formato" && dif=1

    if [[ $dif -eq 1 ]]; then
      echo -n "❓ Deseja gerar o novo arquivo com os dados do CSV? (s/n): "
      read continuar

      if [[ "$continuar" == "s" || "$continuar" == "S" ]]; then
        sed \
          -e "s/{{LABEL_FULL}}/$LABEL_FULL/g" \
          -e "s/{{DOMINIO_CANAL}}/$CANAL/g" \
          -e "s/{{DOMINIO_FORMATO}}/$FORMATO/g" \
          "$TEMPLATE" > "$XML_NOVO"
        echo "✅ Gerado novo XML em: $XML_NOVO"
      else
        echo "⏭️  Arquivo não gerado conforme solicitado."
      fi
    else
      echo "✅ Custom Metadata já está correto. Nenhuma ação necessária."
    fi
  else
    echo "⚠️  Arquivo XML não encontrado em $ENTRADA_XML"
    echo -n "❓ Deseja gerar o novo arquivo com os dados do CSV? (s/n): "
    read continuar

    if [[ "$continuar" == "s" || "$continuar" == "S" ]]; then
      sed \
        -e "s/{{LABEL_FULL}}/$LABEL_FULL/g" \
        -e "s/{{DOMINIO_CANAL}}/$CANAL/g" \
        -e "s/{{DOMINIO_FORMATO}}/$FORMATO/g" \
        "$TEMPLATE" > "$XML_NOVO"
      echo "✅ Gerado novo XML em: $XML_NOVO"
    else
      echo "⏭️  Arquivo não gerado conforme solicitado."
    fi
  fi
done

echo ""
echo "🏁 FIM DO PROCESSAMENTO"
