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
    echo "❌ Certifique-se de que existe projeto criado no VSCode para poder executar todo processo."
    echo "❌ Será necessário fazer o retrieve (de org produção) E deploy (para sandbox de desenvolvimento)."
    exit 1
fi

echo "🔍 Verificando se aliases SFDX estão configurados (com 'sf org list --all --json')..."

# Verifica se o alias do projeto está presente
if ! sf org list --all --json | grep -q "\"alias\": \"$orgAliasProjeto\""; then
    echo "❌ Alias '$orgAliasProjeto' não está configurado nesta máquina."
    echo "   → Verifique se você fez login com esse alias via 'sf org login web --alias $orgAliasProjeto'"
    exit 1
fi

# Verifica se o alias da org de retrieve está presente
if ! sf org list --all --json | grep -q "\"alias\": \"$orgAliasRetrieve\""; then
    echo "❌ Alias '$orgAliasRetrieve' não está configurado nesta máquina."
    echo "   → Verifique se você fez login com esse alias via 'sf org login web --alias $orgAliasRetrieve'"
    exit 1
fi

echo "✅ Aliases verificados com sucesso!"

# Confirma com o usuário se deseja continuar
echo "✅ Tudo pronto. Deseja continuar com a execução? (s/n)"
read resposta
if [ "$resposta" != "s" ]; then
    echo "Execução cancelada pelo usuário."
    exit 0
fi

echo "🚀 Pode iniciar a execução do 10_extract_metadata.sh"
# Aqui você colocaria a lógica principal do seu script
