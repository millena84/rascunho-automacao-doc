#!/bin/bash

TEMPLATE="./_metadados/BaseCustomMetadata.xml"
CSV="./_metadados/041_listaNovosCustom.csv"
SAIDA="./saida_xml"

mkdir -p "$SAIDA"

echo ""
echo "📋 INÍCIO DA GERAÇÃO DE CUSTOM METADATA"
echo "------------------------------------------"

# Lê o CSV (pulando cabeçalho)
mapfile -t linhas < <(tail -n +2 "$CSV")

for linha in "${linhas[@]}"; do
  # Lê os campos da linha atual
  IFS=";" read -r NOME_XML LABEL CAMPO_REL_OBJ_FILHO CAMPO_REL_OBJ_PAI CAMPOS_TELA CAN FOR OBJ_ESPEC TELA_USA <<< "$linha"

  echo ""
  echo "🔍 [$NOME_XML]"

  LABEL_ESCAPADA=$(echo "$LABEL" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')

  sed \
    -e "s/{{NOME_XML}}/$NOME_XML/g" \
    -e "s/{{LABEL}}/$LABEL_ESCAPADA/g" \
    -e "s/{{CAMPO_REL_OBJ_FILHO}}/$CAMPO_REL_OBJ_FILHO/g" \
    -e "s/{{CAMPO_REL_OBJ_PAI}}/$CAMPO_REL_OBJ_PAI/g" \
    -e "s/{{CAMPOS_TELA}}/$CAMPOS_TELA/g" \
    -e "s/{{CAN}}/$CAN/g" \
    -e "s/{{FOR}}/$FOR/g" \
    -e "s/{{OBJ_ESPEC}}/$OBJ_ESPEC/g" \
    -e "s/{{TELA_USA}}/$TELA_USA/g" \
    "$TEMPLATE" > "$SAIDA/${NOME_XML}.md-meta.xml"

  echo "✅ Criado: $SAIDA/${NOME_XML}.md-meta.xml"
done

echo ""
echo "🏁 FIM DO PROCESSAMENTO. Arquivos gerados em: $SAIDA"
