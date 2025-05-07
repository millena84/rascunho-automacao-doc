#!/bin/bash

CSV="dados.csv"
ENTRADA="entrada_xml"
SAIDA="saida_xml_corrigidos"

mkdir -p "$SAIDA"

echo ""
echo "📋 INÍCIO DA COMPARAÇÃO DE ARQUIVOS EXISTENTES (Novo = nao)"
echo "-----------------------------------------------------------"

# Lê todas as linhas do CSV, exceto o cabeçalho
mapfile -t linhas < <(tail -n +2 "$CSV")

for linha in "${linhas[@]}"; do
  IFS=";" read -r ARQUIVO APINAME LABEL CANAL FORMATO NOVO <<< "$linha"

  # Só processa se coluna Novo == "nao"
  [[ "${NOVO,,}" != "nao" ]] && continue

  CAMINHO="$ENTRADA/$ARQUIVO"
  DESTINO="$SAIDA/$ARQUIVO"

  echo ""
  echo "🔎 [$ARQUIVO]"

  if [[ -f "$CAMINHO" ]]; then
    # Extrai os valores atuais do XML
    VALOR_XML_CANAL=$(grep -A1 '<field>WWx_Canal__c</field>' "$CAMINHO" | tail -n1 | sed -E 's/.*>(.*)<.*/\1/')
    VALOR_XML_FORMATO=$(grep -A1 '<field>WWx_Formato__c</field>' "$CAMINHO" | tail -n1 | sed -E 's/.*>(.*)<.*/\1/')

    printf -- "- WWx_Canal__c:   %-30s (XML: %s)\n" "$CANAL" "$VALOR_XML_CANAL"
    printf -- "- WWx_Formato__c: %-30s (XML: %s)\n" "$FORMATO" "$VALOR_XML_FORMATO"

    dif=0
    [[ "$CANAL"   != "$VALOR_XML_CANAL"   ]] && echo "⚠️  Diferença em Canal" && dif=1
    [[ "$FORMATO" != "$VALOR_XML_FORMATO" ]] && echo "⚠️  Diferença em Formato" && dif=1

    if [[ $dif -eq 1 ]]; then
      echo -n "❓ Deseja gerar uma nova versão corrigida desse XML? (s/n): "
      read continuar

      if [[ "$continuar" == "s" || "$continuar" == "S" ]]; then
        cp "$CAMINHO" "$DESTINO"
        echo "✅ Arquivo copiado para: $DESTINO (corrigir manualmente ou com script auxiliar)"
      else
        echo "⏭️  Arquivo ignorado conforme solicitado."
      fi
    else
      echo "✅ Arquivo já está coerente com os dados do CSV. Nada a fazer."
    fi
  else
    echo "❌ Arquivo não encontrado em $CAMINHO"
  fi
done

echo ""
echo "🏁 FIM DA COMPARAÇÃO"
