#!/bin/bash

PACKAGE_XML="manifest/package.xml"
ALIAS_ORG="$1"

if [ -z "$ALIAS_ORG" ]; then
  echo "❌ Uso: ./generate_docs_from_package.sh aliasDaOrg"
  exit 1
fi

mkdir -p tmp
mkdir -p _docs/objetcs/custom

# 📦 Extraí todos os objetos do package.xml onde <name> é CustomObject
echo "📦 Lendo objetos do package.xml..."
OBJETOS=$(xmllint --xpath "//types[name='CustomObject']/members/text()" "$PACKAGE_XML" 2>/dev/null)

if [ -z "$OBJETOS" ]; then
  echo "⚠️ Nenhum objeto CustomObject encontrado no package.xml"
  exit 1
fi

IFS=$'\n'
for OBJ in $OBJETOS; do
  echo "🔎 Trabalhando no objeto $OBJ..."

  # 1. Descreve o objeto e salva JSON temporário
  sf data describe sobject --sobject-type "$OBJ" --target-org "$ALIAS_ORG" --json > "tmp/${OBJ}.json"
  
  if [ ! -f "tmp/${OBJ}.json" ]; then
    echo "⚠️ Erro ao descrever o objeto $OBJ. Pulando."
    continue
  fi

  # 2. Gera tabela de campos
  TABLE=$(jq -r '
    .result.fields[] |
    [
      .label,
      .name,
      .type,
      (if .nillable == false then "Sim" else "" end),
      (.inlineHelpText // "-"),
      (.description // "-")
    ] |
    @tsv
  ' "tmp/${OBJ}.json" | awk -F '\t' 'BEGIN {
    print "| label | fullName | type | required | inlineHelpText | description |";
    print "|:------|:---------|:-----|:--------:|:---------------|:------------|";
  } {
    printf "| %s | `%s` | `%s` | %s | %s | %s |\n", $1, $2, $3, $4, $5, $6;
  }')

  MD_FILE="_docs/objetcs/custom/_model-${OBJ}.md"

  if [ -f "$MD_FILE" ]; then
    echo "✏️ Atualizando $MD_FILE..."
    # Atualiza apenas o bloco de campos
    awk -v newTable="$TABLE" '
      BEGIN { inblock=0 }
      /<!-- start-campos -->/ { print; print newTable; inblock=1; next }
      /<!-- end-campos -->/ { inblock=0 }
      !inblock
    ' "$MD_FILE" > "${MD_FILE}.tmp"

    mv "${MD_FILE}.tmp" "$MD_FILE"
  else
    echo "🆕 Criando novo $MD_FILE..."

    cat <<EOF > "$MD_FILE"
# _model-${OBJ} (Custom Object)

## Resumo

<!-- start-resumo -->
(Descrição manual ou extraída futuramente)
<!-- end-resumo -->

---

## Campos

<!-- start-campos -->
$TABLE
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

| Data       | Alteração                  | Responsável         |
|------------|----------------------------|----------------------|
| $(date +%Y-%m-%d) | Criação da documentação inicial | Millena Ferreira       |
EOF

  fi

done

echo "✅ Documentação finalizada com sucesso!"
