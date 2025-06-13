# correcao json
#!/bin/bash

CONFIG="./configuracao.json"
CHAVE_RAIZ="consultas tabelas internas.consultaEntityDefinition"

# Função simples com leitura segura
get_json_value() {
  local path="$1"
  node -e "
    const fs = require('fs');
    const obj = JSON.parse(fs.readFileSync('$CONFIG', 'utf-8'));
    const val = '$path'.split('.').reduce((o, k) => o && o[k], obj);
    console.log(JSON.stringify(val));
  "
}

# Leitura da configuração
INFO_SELECAO=$(get_json_value "$CHAVE_RAIZ.infoSelecao")
INFO_EXCLUSAO=$(get_json_value "$CHAVE_RAIZ.infoExclusao")
CONSIDERAR_ADICIONAIS=$(get_json_value "$CHAVE_RAIZ.considerarTabelasAdicionais" | tr -d '"')
DIRETORIO_SAIDA=$(get_json_value "$CHAVE_RAIZ.diretorioSaida" | tr -d '"')

# Cria diretório de saída se necessário
mkdir -p "$DIRETORIO_SAIDA"
ARQUIVO_SAIDA="$DIRETORIO_SAIDA/saida_entity_definition.json"

# Início do filtro
FILTRO_WHERE=""

# Inclusão
if [[ "$INFO_SELECAO" != "[]" ]]; then
  INCLUDES=()
  for termo in $(echo "$INFO_SELECAO" | jq -r '.[]'); do
    [[ "$termo" != "" ]] && INCLUDES+=("QualifiedApiName LIKE '%$termo%'")
  done
  if [[ ${#INCLUDES[@]} -gt 0 ]]; then
    FILTRO_WHERE+="($(IFS=" OR "; echo "${INCLUDES[*]}"))"
  fi
fi

# Exclusão
if [[ "$INFO_EXCLUSAO" != "[]" ]]; then
  EXCLUDES=()
  for termo in $(echo "$INFO_EXCLUSAO" | jq -r '.[]'); do
    [[ "$termo" != "" ]] && EXCLUDES+=("QualifiedApiName NOT LIKE '%$termo%'")
  done
  if [[ ${#EXCLUDES[@]} -gt 0 ]]; then
    [[ -n "$FILTRO_WHERE" ]] && FILTRO_WHERE+=" AND "
    FILTRO_WHERE+="($(IFS=" AND "; echo "${EXCLUDES[*]}"))"
  fi
fi

# Auxiliares
if [[ "$CONSIDERAR_ADICIONAIS" == "n" ]]; then
  AUX_EXCLUDE="QualifiedApiName NOT LIKE '%__History%' AND QualifiedApiName NOT LIKE '%__Feed%' AND QualifiedApiName NOT LIKE '%ChangeEvent%' AND QualifiedApiName NOT LIKE '%Tag%' AND QualifiedApiName NOT LIKE '%Share%'"
  [[ -n "$FILTRO_WHERE" ]] && FILTRO_WHERE+=" AND "
  FILTRO_WHERE+="($AUX_EXCLUDE)"
fi

# Monta SOQL
if [[ -n "$FILTRO_WHERE" ]]; then
  SOQL="SELECT DurableId, QualifiedApiName FROM EntityDefinition WHERE $FILTRO_WHERE"
else
  SOQL="SELECT DurableId, QualifiedApiName FROM EntityDefinition"
fi

# Executa
echo "🔎 Executando SOQL:"
echo "$SOQL"
sf data query --query "$SOQL" --json > "$ARQUIVO_SAIDA"
echo "✅ Resultado salvo em: $ARQUIVO_SAIDA"

# json simplificado
#GERA SO ED
#!/bin/bash

# Caminhos e arquivos
CONFIG="./configuracao.json"
SAIDA="./saida_entity_definition.json"

# Função simples para pegar valores de arrays ou campos únicos
get_json_value() {
  local path="$1"
  node -e "
    const obj = require('$CONFIG');
    const val = '$path'.split('.').reduce((o, k) => (o || {})[k], obj);
    console.log(JSON.stringify(val));
  "
}

# Pega os valores do JSON
INFO_SELECAO=$(get_json_value "infoSelecao")
INFO_EXCLUSAO=$(get_json_value "infoExclusao")
CONSIDERAR_ADICIONAIS=$(get_json_value "considerarTabelasAdicionais" | tr -d '"')

# Inicializa filtros
FILTRO_WHERE=""

# Processa infoSelecao
if [[ "$INFO_SELECAO" != "[]" ]]; then
  LIKE_PARTS=()
  for termo in $(echo "$INFO_SELECAO" | jq -r '.[]'); do
    [[ "$termo" != "" ]] && LIKE_PARTS+=("QualifiedApiName LIKE '%$termo%'")
  done

  if [[ ${#LIKE_PARTS[@]} -gt 0 ]]; then
    FILTRO_WHERE+="($(IFS=" OR "; echo "${LIKE_PARTS[*]}"))"
  fi
fi

# Processa infoExclusao
if [[ "$INFO_EXCLUSAO" != "[]" ]]; then
  NOT_PARTS=()
  for termo in $(echo "$INFO_EXCLUSAO" | jq -r '.[]'); do
    [[ "$termo" != "" ]] && NOT_PARTS+=("QualifiedApiName NOT LIKE '%$termo%'")
  done

  if [[ ${#NOT_PARTS[@]} -gt 0 ]]; then
    [[ -n "$FILTRO_WHERE" ]] && FILTRO_WHERE+=" AND "
    FILTRO_WHERE+="($(IFS=" AND "; echo "${NOT_PARTS[*]}"))"
  fi
fi

# Considerar tabelas auxiliares?
if [[ "$CONSIDERAR_ADICIONAIS" == "n" ]]; then
  AUXILIARES="QualifiedApiName NOT LIKE '%__History%' AND QualifiedApiName NOT LIKE '%__Feed%' AND QualifiedApiName NOT LIKE '%ChangeEvent%' AND QualifiedApiName NOT LIKE '%Tag%' AND QualifiedApiName NOT LIKE '%Share%'"
  [[ -n "$FILTRO_WHERE" ]] && FILTRO_WHERE+=" AND "
  FILTRO_WHERE+="($AUXILIARES)"
fi

# Monta a SOQL final
if [[ -n "$FILTRO_WHERE" ]]; then
  SOQL="SELECT DurableId, QualifiedApiName FROM EntityDefinition WHERE $FILTRO_WHERE"
else
  SOQL="SELECT DurableId, QualifiedApiName FROM EntityDefinition"
fi

# Executa a query
echo "🔎 Executando SOQL:"
echo "$SOQL"
sf data query --query "$SOQL" --json > "$SAIDA"
echo "✅ Resultado salvo em: $SAIDA"


# GERAVA TUDO JUNTO
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
