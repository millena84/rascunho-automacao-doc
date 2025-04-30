#!/bin/bash

# Mimi: script para gerar documentação Markdown de um objeto Salesforce DX

echo "Digite o API Name do objeto (ex: ATU_nmCustomObj__c):"
read OBJ_API

# Diretórios fixos
OBJ_DIR="force-app/main/default/objects/$OBJ_API"
XML_FILE="$OBJ_DIR/$OBJ_API.object-meta.xml"
DEST_DIR="_docs/_org/obj/custom"
ARQUIVO_MD="$DEST_DIR/_model-$OBJ_API.md"

# Verificações básicas
if [ ! -f "$XML_FILE" ]; then
  echo "❌ Arquivo $XML_FILE não encontrado."
  exit 1
fi

mkdir -p "$DEST_DIR"

# Pega data atual
DATA_HOJE=$(date "+%Y-%m-%d")

# Extrai descrição do objeto
DESC_OBJETO=$(grep -oPm1 "(?<=<description>)[^<]+" "$XML_FILE")

# Início do Markdown
cat > "$ARQUIVO_MD" << EOL
# _model-$OBJ_API (Custom Object)

<!-- Resumo: description -->
## Resumo

<!-- start-resumo -->
${DESC_OBJETO:-Descrição extraída do metadata aqui.}
<!-- end-resumo -->

---

## Campos

<!-- start-campos -->

| label | fullName | type | required | inlineHelpText |  description |
|:------|:---------|:-----|:---------|:---------------|:-------------|
EOL

# Extrai campos e preenche tabela
for FIELD_FILE in "$OBJ_DIR/fields/"*.field-meta.xml; do
  LABEL=$(grep -oPm1 "(?<=<label>)[^<]+" "$FIELD_FILE")
  API=$(basename "$FIELD_FILE" .field-meta.xml)
  TYPE=$(grep -oPm1 "(?<=<type>)[^<]+" "$FIELD_FILE")
  REQUIRED=$(grep -q "<required>true</required>" "$FIELD_FILE" && echo "Sim" || echo "Não")
  HELPTEXT=$(grep -oPm1 "(?<=<inlineHelpText>)[^<]+" "$FIELD_FILE" || echo "-")
  DESCRIPTION=$(grep -oPm1 "(?<=<description>)[^<]+" "$FIELD_FILE" || echo "-")

  echo "| $LABEL | $API | $TYPE | $REQUIRED | $HELPTEXT | $DESCRIPTION |" >> "$ARQUIVO_MD"
done

cat >> "$ARQUIVO_MD" << EOL

(gerado automaticamente)
<!-- end-campos -->

---

## Features Declarativas onde aparece
- (Preencher manualmente)

---

## Código High-Code relacionado
- (Preencher manualmente)

---

## Interfaces e Telas
- (Preencher manualmente)

---

## Notas Técnicas
- (Preencher manualmente)

---

## Histórico de Alterações
<!-- preencher manualmente -->

| Data | Alteração | Responsável |
|:-----|:----------|:------------|
| $DATA_HOJE | Criação da documentação inicial | Millena Ferreira |
EOL

echo "✅ Documentação gerada em: $ARQUIVO_MD"
