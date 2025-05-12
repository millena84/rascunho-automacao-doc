#!/bin/bash

ARQ_JSON="11_extract_org_metadata.json"

# Carrega variáveis do JSON com grep e cut
get_val_json() {
    grep "\"$1\"" "$ARQ_JSON" | cut -d ':' -f2- | sed 's/[",]//g' | xargs
}

echo "Lendo configurações do arquivo: $ARQ_JSON"
orgAliasProjeto=$(get_val_json "orgAliasProjeto")
orgAliasRetrieve=$(get_val_json "orgAliasRetrieve")
dirAlteracao=$(get_val_json "diretorioAlteracaoCustomMtdLote")
dirArqSfdx=$(get_val_json "diretorioArqSfdxProject")
dirProjetosSF=$(get_val_json "diretorioProjetosSF")

# Validação de diretório atual
echo "Validando se o diretório atual é: $dirAlteracao"
if [ "$(pwd)" != "$dirAlteracao" ]; then
    echo "❌ Diretório incorreto. Vá para: $dirAlteracao"
    exit 1
fi

# Valida existência do sfdx-project.json
if [ ! -f "$dirArqSfdx/sfdx-project.json" ]; then
    echo "❌ Arquivo sfdx-project.json não encontrado em $dirArqSfdx"
    exit 1
fi

# Verifica se o diretório de projetos existe
if [ ! -d "$dirProjetosSF" ]; then
    echo "❌ Diretório $dirProjetosSF não encontrado."
    exit 1
fi

# Valida se aliases existem via sfdx
echo "Verificando se aliases SFDX estão configurados..."
sfdx aliases:list | grep -q "$orgAliasProjeto"
if [ $? -ne 0 ]; then
    echo "❌ Alias $orgAliasProjeto não configurado."
    exit 1
fi

sfdx aliases:list | grep -q "$orgAliasRetrieve"
if [ $? -ne 0 ]; then
    echo "❌ Alias $orgAliasRetrieve não configurado."
    exit 1
fi

# Confirma com o usuário se deseja continuar
echo "✅ Tudo pronto. Deseja continuar com a execução? (s/n)"
read resposta
if [ "$resposta" != "s" ]; then
    echo "Execução cancelada pelo usuário."
    exit 0
fi

echo "🚀 Pode iniciar a execução do 10_extract_metadata.sh"
# Aqui você colocaria a lógica principal do seu script
