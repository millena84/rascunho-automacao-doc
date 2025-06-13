#!/bin/bash

OUTDIR="./saida_metadados"
mkdir -p "$OUTDIR/fields"
mkdir -p "$OUTDIR/perms"

ENTITY_FILE="$OUTDIR/entity_definitions.json"
FINAL_JSON="$OUTDIR/entity_field_permissions.json"

echo "🎯 Etapa 1: Consultando todos os EntityDefinition..."
sf data query --query "SELECT DurableId, QualifiedApiName FROM EntityDefinition" --json > "$ENTITY_FILE"

echo "[" > "$FINAL_JSON"
FIRST=true

echo "🔁 Processando registros..."

BLOCK=""
IN_BLOCK=0

while IFS= read -r line || [[ -n "$line" ]]; do
  # Início de um bloco JSON
  if [[ $line =~ ^[[:space:]]*{ ]]; then
    IN_BLOCK=1
    BLOCK="$line"
    continue
  fi

  if [[ $IN_BLOCK -eq 1 ]]; then
    BLOCK="${BLOCK}"$'\n'"$line"
  fi

  # Fim do bloco
  if [[ $IN_BLOCK -eq 1 && $line =~ ^[[:space:]]*} ]]; then
    IN_BLOCK=0

    DURABLE_ID=$(echo "$BLOCK" | grep '"DurableId":' | sed 's/.*"DurableId": *"//' | sed 's/".*//')
    API_NAME=$(echo "$BLOCK" | grep '"QualifiedApiName":' | sed 's/.*"QualifiedApiName": *"//' | sed 's/".*//')

    if [[ -z "$API_NAME" ]] || [[ "$API_NAME" =~ (Feed$|History$|Tag$|Share$|ChangeEvent$) ]]; then
      echo "⏭️  Ignorando: $API_NAME"
      continue
    fi

    echo "🔎 Processando: $API_NAME"

    # Etapa 3: Campos
    FIELDS_FILE="$OUTDIR/fields/fields_${API_NAME}.json"
    sf data query --query "SELECT DeveloperName, QualifiedApiName, Label, DataType, Description, IsFieldHistoryTracked FROM FieldDefinition WHERE EntityDefinition.DurableId = '$DURABLE_ID'" --json > "$FIELDS_FILE"

    if ! grep -q '"EntityDefinitionId":' "$FIELDS_FILE"; then
      echo "⚠️  Nenhum campo retornado para $API_NAME — pulando..."
      continue
    fi

    # Etapa 4: Permissões
    PERMS_FILE="$OUTDIR/perms/perms_${API_NAME}.json"
    sf data query --query "SELECT Field, PermissionsRead, PermissionsEdit, ParentId FROM FieldPermissions WHERE SObjectType = '$API_NAME'" --json > "$PERMS_FILE"

    # JSON final
    if [ "$FIRST" = false ]; then
      echo "," >> "$FINAL_JSON"
    fi
    FIRST=false

    echo "{" >> "$FINAL_JSON"
    echo "  \"QualifiedApiName\": \"$API_NAME\"," >> "$FINAL_JSON"
    echo "  \"DurableId\": \"$DURABLE_ID\"," >> "$FINAL_JSON"

    echo "  \"fields\": [" >> "$FINAL_JSON"
    grep -A1000 '"records": ' "$FIELDS_FILE" | sed '/,/q' | sed '1d' | sed '$d' >> "$FINAL_JSON"
    echo "  ]," >> "$FINAL_JSON"

    echo "  \"fieldPermissions\": [" >> "$FINAL_JSON"
    grep -A1000 '"records": ' "$PERMS_FILE" | sed '/,/q' | sed '1d' | sed '$d' >> "$FINAL_JSON"
    echo "  ]" >> "$FINAL_JSON"

    echo "}" >> "$FINAL_JSON"
  fi
done < "$ENTITY_FILE"

echo "]" >> "$FINAL_JSON"
echo "✅ JSON final salvo em: $FINAL_JSON"

# extrai info tbs entity field definition para analise
