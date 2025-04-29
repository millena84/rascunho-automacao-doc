#!/bin/bash

OBJETOS_DIR="force-app/main/default/objects"
OUTPUT_DIR="_docs/objetos/custom"

mkdir -p "$OUTPUT_DIR"

for OBJETO_DIR in "$OBJETOS_DIR"/*; do
    OBJETO_NAME=$(basename "$OBJETO_DIR")
    XML_FILE="$OBJETO_DIR/$OBJETO_NAME.object-meta.xml"

    if [ -f "$XML_FILE" ]; then
        OUTPUT_FILE="$OUTPUT_DIR/${OBJETO_NAME}.md"

        TEMP_FILE="${OUTPUT_FILE}.tmp"

        # Buscar a descrição do objeto
        OBJECT_DESCRIPTION=$(grep -oPm1 "(?<=<description>)[^<]+" "$XML_FILE")

        # Se o arquivo ainda não existir, cria um novo vazio
        if [ ! -f "$OUTPUT_FILE" ]; then
            touch "$OUTPUT_FILE"
        fi

        # Cria o conteúdo temporário
        {
            echo "# ${OBJETO_NAME}"
            echo ""
            echo "## Resumo"
            echo ""
            echo "<!-- start-resumo -->"
            if [ -n "$OBJECT_DESCRIPTION" ]; then
                echo "$OBJECT_DESCRIPTION"
            else
                echo "_Descrição não disponível no metadata._"
            fi
            echo "<!-- end-resumo -->"
            echo ""
            echo "---"
            echo ""
            echo "## Campos"
            echo ""
            echo "<!-- start-campos -->"
            echo "| Label | API Name | Tipo | Obrigatório | Help Text | Description |"
            echo "|:------|:---------|:-----|:------------|:----------|:------------|"

            awk '
                /<fields>/ {inField=1; label=""; fullName=""; type=""; required="Não"; helpText=""; description=""}
                /<\/fields>/ {
                    print "| " label " | " fullName " | " type " | " required " | " helpText " | " description " |";
                    inField=0
                }
                inField && /<label>/ {
                    label=gensub(/.*<label>(.*)<\/label>.*/, "\\1", "g")
                }
                inField && /<fullName>/ {
                    fullName=gensub(/.*<fullName>(.*)<\/fullName>.*/, "\\1", "g")
                }
                inField && /<type>/ {
                    type=gensub(/.*<type>(.*)<\/type>.*/, "\\1", "g")
                }
                inField && /<required>/ {
                    requiredValue=gensub(/.*<required>(.*)<\/required>.*/, "\\1", "g")
                    required=(requiredValue=="true" ? "Sim" : "Não")
                }
                inField && /<inlineHelpText>/ {
                    helpText=gensub(/.*<inlineHelpText>(.*)<\/inlineHelpText>.*/, "\\1", "g")
                }
                inField && /<description>/ {
                    description=gensub(/.*<description>(.*)<\/description>.*/, "\\1", "g")
                }
            ' "$XML_FILE"

            echo "<!-- end-campos -->"
            echo ""
        } > "$TEMP_FILE"

        # Preserva informações manuais antigas
        if grep -q "<!-- start-campos -->" "$OUTPUT_FILE"; then
            sed -n '/<!-- start-campos -->/,/<!-- end-campos -->/!p' "$OUTPUT_FILE" >> "$TEMP_FILE"
        fi

        # Substitui o arquivo original
        mv "$TEMP_FILE" "$OUTPUT_FILE"
    fi
done
