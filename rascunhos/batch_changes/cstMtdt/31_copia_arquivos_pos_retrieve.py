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

# === Parâmetros e leitura do JSON ===
ARQ_EXECUCAO = "11_extract_org_metadata.json"

with open(ARQ_EXECUCAO, "r", encoding="utf-8") as f:
    config = json.load(f)

origem_base = path_gitbash_para_windows(config.get("diretorioProjetosSF", ""))
destino_base = path_gitbash_para_windows(config.get("diretorioAlteracaoCustomMtdLote", ""))
filtro_nome = config.get("filtroNomeArquivo", "").strip()
dir_componente = config.get("diretorioComponente", "").strip()

if not filtro_nome or not dir_componente:
    print("❌ Campos obrigatórios ausentes: 'filtroNomeArquivo' ou 'diretorioComponente'")
    exit(1)

# Garante que 'dir_componente' não vai sobrescrever o caminho base
dir_componente = dir_componente.lstrip("/\\")
pasta_origem = os.path.normpath(os.path.join(origem_base, dir_componente))

# Timestamp formatado de forma segura para nome de pasta
timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
nome_seguro = f"entrada_xml_{filtro_nome}_{timestamp}".replace(":", "_").replace("/", "_").replace("\\", "_").replace(" ", "_")
pasta_destino = os.path.join(destino_base, "bckp_preRet", nome_seguro)
os.makedirs(pasta_destino, exist_ok=True)

# Logs iniciais
print()
print(f"🔎 Procurando arquivos com '{filtro_nome}'")
print(f"📂 Origem  : {pasta_origem}")
print(f"📁 Destino : {pasta_destino}")
print()

# Verifica origem
if not os.path.isdir(pasta_origem):
    print(f"❌ Pasta de origem não encontrada: {pasta_origem}")
    exit(1)

# Cópia dos arquivos que batem com o filtro
copiados = 0
for root, _, files in os.walk(pasta_origem):
    for file in files:
        if filtro_nome in file:
            origem_path = os.path.join(root, file)
            caminho_relativo = os.path.relpath(origem_path, pasta_origem)
            destino_path = os.path.join(pasta_destino, caminho_relativo)

            os.makedirs(os.path.dirname(destino_path), exist_ok=True)
            shutil.copy2(origem_path, destino_path)
            print(f"✅ Copiado: {caminho_relativo}")
            copiados += 1

# Finalização
print()
if copiados == 0:
    print(f"⚠️ Nenhum arquivo contendo '{filtro_nome}' foi encontrado.")
else:
    print(f"🎉 {copiados} arquivo(s) copiado(s) com sucesso.")
    print(f"📦 Conteúdo salvo em: {pasta_destino}")
