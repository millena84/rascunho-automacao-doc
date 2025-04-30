# for para pegar status
for FIELD_FILE in "$DIR_OBJ/fields/"*.field-meta.xml; do
  TYPE=$(grep -oPm1 "(?<=<type>)[^<]+" "$FIELD_FILE")

  if [[ "$TYPE" == "Picklist" ]]; then
    echo "Valores da picklist de $FIELD_FILE:"

    grep -A1 "<value>" "$FIELD_FILE" | while read -r linha; do
      # Verifica se está lendo a linha com fullName
      if [[ "$linha" =~ \<fullName\>(.*)\<\/fullName\> ]]; then
        NOME=${BASH_REMATCH[1]}
      fi

      if [[ "$linha" =~ \<label\>(.*)\<\/label\> ]]; then
        ROTULO=${BASH_REMATCH[1]}
        echo " - $NOME ($ROTULO)"
      fi
    done
  fi
done



# status formatando tabela:
if [[ "$TYPE" == "Picklist" ]]; then
  echo "" >> "$ARQUIVO_MD"
  echo "### Valores para o campo: $LABEL - $API" >> "$ARQUIVO_MD"
  echo "" >> "$ARQUIVO_MD"
  echo "| label | fullName | status | default |" >> "$ARQUIVO_MD"
  echo "|:------|:---------|:--------|:--------|" >> "$ARQUIVO_MD"

  # Extrai o bloco de cada value
  awk '/<value>/,/<\/value>/' "$FIELD_FILE" | paste -sd'\n' - | while read -r bloco; do
    LABEL=$(echo "$bloco" | grep -oPm1 "(?<=<label>)[^<]*")
    FULLNAME=$(echo "$bloco" | grep -oPm1 "(?<=<fullName>)[^<]*")
    STATUS=$(echo "$bloco" | grep -oPm1 "(?<=<status>)[^<]*")
    ISDEFAULT=$(echo "$bloco" | grep -oPm1 "(?<=<default>)[^<]*")
    [ "$ISDEFAULT" == "true" ] && ISDEFAULT="Sim" || ISDEFAULT="Não"

    # Escapando pipe para evitar quebra de Markdown
    LABEL=$(echo "$LABEL" | sed 's/|/\\|/g')
    FULLNAME=$(echo "$FULLNAME" | sed 's/|/\\|/g')

    printf "| %s | %s | %s | %s |\n" "$LABEL" "$FULLNAME" "$STATUS" "$ISDEFAULT" >> "$ARQUIVO_MD"
  done
fi


## formata valor picklist 2:
if [[ "$TYPE" == "Picklist" ]]; then
  echo "" >> "$ARQUIVO_MD"
  echo "### Valores para o campo: $LABEL - $API" >> "$ARQUIVO_MD"
  echo "" >> "$ARQUIVO_MD"
  echo "| label | fullName | status | default |" >> "$ARQUIVO_MD"
  echo "|:------|:---------|:--------|:--------|" >> "$ARQUIVO_MD"

  in_value_block=false
  LABEL=""
  FULLNAME=""
  STATUS=""
  DEFAULT=""

  while IFS= read -r line; do
    [[ "$line" == *"<value>"* ]] && in_value_block=true
    [[ "$line" == *"</value>"* ]] && {
      # Linha pronta
      [[ "$DEFAULT" == "true" ]] && DEFAULT="Sim" || DEFAULT="Não"
      printf "| %s | %s | %s | %s |\n" "$LABEL" "$FULLNAME" "$STATUS" "$DEFAULT" >> "$ARQUIVO_MD"
      # Reseta
      in_value_block=false
      LABEL=""; FULLNAME=""; STATUS=""; DEFAULT=""
    }

    if $in_value_block; then
      [[ "$line" =~ \<label\>(.*)\</label\> ]] && LABEL="${BASH_REMATCH[1]}"
      [[ "$line" =~ \<fullName\>(.*)\</fullName\> ]] && FULLNAME="${BASH_REMATCH[1]}"
      [[ "$line" =~ \<status\>(.*)\</status\> ]] && STATUS="${BASH_REMATCH[1]}"
      [[ "$line" =~ \<default\>(.*)\</default\> ]] && DEFAULT="${BASH_REMATCH[1]}"
    fi
  done < "$FIELD_FILE"
fi

# formata picklist 3
if [[ "$TYPE" == "Picklist" ]]; then
  echo "" >> "$ARQUIVO_MD"
  echo "### Valores para o campo: $LABEL - $API" >> "$ARQUIVO_MD"
  echo "" >> "$ARQUIVO_MD"
  echo "| label | fullName | status | default |" >> "$ARQUIVO_MD"
  echo "|:------|:---------|:--------|:--------|" >> "$ARQUIVO_MD"

  in_block=false
  LABEL=""
  FULLNAME=""
  STATUS=""
  DEFAULT=""

  while IFS= read -r line; do
    if [[ "$line" =~ \<value\> ]]; then
      in_block=true
    elif [[ "$line" =~ \<\/value\> ]]; then
      [[ "$DEFAULT" == "true" ]] && DEFAULT="Sim" || DEFAULT="Não"
      printf "| %s | %s | %s | %s |\n" "$LABEL" "$FULLNAME" "$STATUS" "$DEFAULT" >> "$ARQUIVO_MD"
      LABEL=""; FULLNAME=""; STATUS=""; DEFAULT=""; in_block=false
    fi

    if $in_block; then
      [[ "$line" =~ \<label\>(.*)\</label\> ]] && LABEL="${BASH_REMATCH[1]}"
      [[ "$line" =~ \<fullName\>(.*)\</fullName\> ]] && FULLNAME="${BASH_REMATCH[1]}"
      [[ "$line" =~ \<status\>(.*)\</status\> ]] && STATUS="${BASH_REMATCH[1]}"
      [[ "$line" =~ \<default\>(.*)\</default\> ]] && DEFAULT="${BASH_REMATCH[1]}"
    fi
  done < "$FIELD_FILE"
fi

# formata picklist 4:
if [[ "$TYPE" == "Picklist" ]]; then
  echo "" >> "$ARQUIVO_MD"
  echo "### Valores para o campo: $LABEL - $API" >> "$ARQUIVO_MD"
  echo "" >> "$ARQUIVO_MD"
  echo "| label | fullName | status | default |" >> "$ARQUIVO_MD"
  echo "|:------|:---------|:--------|:--------|" >> "$ARQUIVO_MD"

  in_block=false
  LABEL=""; FULLNAME=""; STATUS=""; DEFAULT=""

  while IFS= read -r line; do
    line=$(echo "$line" | sed 's/^[[:space:]]*//')  # remove espaços no início

    if [[ "$line" == "<value>" ]]; then
      in_block=true
    elif [[ "$line" == "</value>" ]]; then
      [[ "$DEFAULT" == "true" ]] && DEFAULT="Sim" || DEFAULT="Não"
      printf "| %s | %s | %s | %s |\n" "$LABEL" "$FULLNAME" "$STATUS" "$DEFAULT" >> "$ARQUIVO_MD"
      LABEL=""; FULLNAME=""; STATUS=""; DEFAULT=""; in_block=false
    fi

    if $in_block; then
      [[ "$line" =~ \<label\>(.*)\</label\> ]] && LABEL="${BASH_REMATCH[1]}"
      [[ "$line" =~ \<fullName\>(.*)\</fullName\> ]] && FULLNAME="${BASH_REMATCH[1]}"
      [[ "$line" =~ \<status\>(.*)\</status\> ]] && STATUS="${BASH_REMATCH[1]}"
      [[ "$line" =~ \<default\>(.*)\</default\> ]] && DEFAULT="${BASH_REMATCH[1]}"
    fi
  done < "$FIELD_FILE"
fi
