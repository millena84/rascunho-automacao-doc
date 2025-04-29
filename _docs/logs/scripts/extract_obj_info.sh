#!/bin/bash

OBJ_API_NAME="$1"
ALIAS_ORG="$2"

if [ -z "$OBJ_API_NAME" ] || [ -z "$ALIAS_ORG" ]; then
  echo "❌ Uso: ./generate_object_md.sh NomeDoObjeto__c aliasDaOrg"
  exit 1
fi

mkdir -p tmp
mkdir -p _docs/objetcs/custom

JSON_FILE="tmp/${OBJ_API_NAME}_describe.json"
MD_FILE="_docs/objetcs/custom/_model-${OBJ_API_NAME}.md"

# 1. Extrair JSON
sf data describe sobject --sobject-type "$OBJ_API_NAME" --target-org "$ALIAS_ORG" --json > "$JSON_FILE"

# 2. Captura a descrição do objeto
OBJ_LABEL=$(jq -r '.result.label' "$JSON_FILE")
OBJ_DESCRIPTION=$(jq -r '.result.description // "Descrição extraída do metadata aqui."' "$JSON_FILE")

# 3. Começa o markdown
cat <<EOF > "$MD_FILE"
# _model-${OBJ_API_NAME} (Custom Object)

<!-- Resumo: description -->
## Resumo

<!-- start-resumo -->
$OBJ_DESCRIPTION
<!-- end-resumo -->

---

## Campos

<!-- start-campos -->

| label | fullName | type | required | inlineHelpText | description |
|:------|:---------|:-----|:--------:|:---------------|:------------|
EOF

# 4. Adiciona a tabela com os campos
jq -r '
  .result.fields[] |
  "| " +
  (.label // "-") + " | " +
  (.name // "-") + " | " +
  (.type // "-") + " | " +
  (if .nillable == false then "Sim" else "Não" end) + " | " +
  (.inlineHelpText // "-") + " | " +
  (.description // "-") + " |"
' "$JSON_FILE" >> "$MD_FILE"

# 5. Finaliza com seções manuais
cat <<EOF >> "$MD_FILE"

(gerado automaticamente)
<!-- end-campos -->

---

## Features Declarativas onde aparece
- (Preencher manualmente)

---

## Código back-end (Classe, Trigger)
- (Preencher manualmente)

---

## Componentes (Interfaces e Telas)
- (Preencher manualmente)

---

## Notas Técnicas
- (Preencher manualmente)

---

## Histórico de Alterações
<!-- preencher manualmente -->

| Data | Alteração | Responsável |
|:-----|:----------|:------------|
| $(date +%Y-%m-%d) | Criação da documentação inicial | Millena Ferreira |
EOF

echo "✅ Documentação gerada: $MD_FILE"
