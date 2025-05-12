import os
import shutil
import json
from datetime import datetime

# === Função para converter caminhos estilo Git Bash para Windows ===
def path_gitbash_para_windows(caminho):
    if caminho.startswith("/"):
        partes = caminho.strip("/").split("/", 1)
        if len(partes) == 2 and len(partes[0]) == 1:
            drive = partes[0].upper()
            resto = partes[1]
            return os.path.abspath(os.path.normpath(f"{drive}:/{resto}"))
    return os.path.abspath(os.path.normpath(caminho))

# === Parâmetros ===
ARQ_EXECUCAO = "11_extract_org_metadata.json"

with open(ARQ_EXECUCAO, "r", encoding="utf-8") as f:
    config = json.load(f)

# Extrai parâmetros convertendo caminhos
origem_base = path_gitbash_para_windows(config.get("diretorioProjetosSF", ""))
destino_base = path_gitbash_para_windows(config.get("diretorioAlteracaoCustomMtdLote", ""))
filtro_nome = config.get("filtroNomeArquivo", "").strip()
dir_componente = config.get("diretorioComponente", "").strip()

# Valida obrigatórios
if not filtro_nome or not dir_componente:
    print("❌ Campos obrigatórios 'filtroNomeArquivo' ou 'diretorioComponente' ausentes.")
    exit(1)

# Caminhos finais
pasta_origem = os.path.join(origem_base, dir_componente)
timestamp = datetime.now().strftime("%Y%m%d-%H-%M")
destino_filtrado = os.path.join(destino_base, "bckp_preRet", f"entrada_xml_{filtro_nome}_{timestamp}")
os.makedirs(destino_filtrado, exist_ok=True)

# Debug
print(f"\n🔎 Procurando arquivos contendo '{filtro_nome}' em: {pasta_origem}")
print(f"📂 Salvando cópias em: {destino_filtrado}\n")

# Execução
copiados = 0

if not os.path.isdir(pasta_origem):
    print(f"❌ Pasta de origem não encontrada: {pasta_origem}")
    exit(1)

for root, _, files in os.walk(pasta_origem):
    for file in files:
        if filtro_nome in file:
            origem_path = os.path.join(root, file)
            caminho_relativo = os.path.relpath(origem_path, pasta_origem)
            destino_path = os.path.join(destino_filtrado, caminho_relativo)

            os.makedirs(os.path.dirname(destino_path), exist_ok=True)
            shutil.copy2(origem_path, destino_path)
            print(f"✅ Copiado: {caminho_relativo}")
            copiados += 1

# Finalização
print()
if copiados == 0:
    print("⚠️ Nenhum arquivo encontrado com o filtro.")
else:
    print(f"🎉 {copiados} arquivo(s) copiado(s) com filtro '{filtro_nome}'.")
    print(f"📦 Pasta de destino: {destino_filtrado}")
