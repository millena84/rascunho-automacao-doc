#!/bin/bash

OUTPUT_DIR="_docs/objetos/custom"

mkdir -p "$OUTPUT_DIR"

echo "Digite o nome do objeto (exemplo: Conta__c):"
read OBJETO

OUTPUT_FILE="$OUTPUT_DIR/${OBJETO}.md"

if [ -f "$OUTPUT_FILE" ]; then
    echo "Verificando: $(basename "$OUTPUT_FILE")"

    for SECTION in "Features Declarativas onde aparece" "Código High-Code relacionado" "Interfaces e Telas" "Notas Técnicas" "Histórico de Alterações"; do
        if ! grep -q "## $SECTION" "$OUTPUT_FILE"; then
            echo "" >> "$OUTPUT_FILE"
            echo "---" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            echo "## $SECTION" >> "$OUTPUT_FILE"
            case "$SECTION" in
                "Histórico de Alterações")
                    echo "" >> "$OUTPUT_FILE"
                    echo "| Data | Alteração | Responsável |" >> "$OUTPUT_FILE"
                    echo "|:-----|:----------|:------------|" >> "$OUTPUT_FILE"
                    ;;
                *)
                    echo "- (Preencher manualmente)" >> "$OUTPUT_FILE"
                    ;;
            esac
            echo "Seção \"$SECTION\" criada."
        else
            echo "Seção \"$SECTION\" já existe."
        fi
    done

else
    echo "Arquivo $OUTPUT_FILE não encontrado."
    echo "Execute primeiro o script gerar_docs_campos.sh para gerar o arquivo base deste objeto."
fi
