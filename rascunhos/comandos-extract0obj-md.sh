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
