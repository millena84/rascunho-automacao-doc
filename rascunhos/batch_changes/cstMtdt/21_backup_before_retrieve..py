import os
import shutil
import json
from datetime import datetime

# === Função para converter caminho do Git Bash para Windows ===
def path_gitbash_para_windows(caminho):
    """
    Converte caminhos como /c/Users/... em C:/Users/... de forma segura
    """
    if caminho.startswith("/") and len(caminho) > 2 and caminho[2] == '/':
        drive = caminho[1]
        resto = caminho[2:]
        return os.path.normpath(f"{drive.upper()}:/{resto}")
    return os.path.normpath(caminho)

# === Arquivos de entrada ===
ARQ_EXECUCAO = "11_extract_org_metadata.json"
ARQ_MAPA_PASTAS = "21_mapa_pastas_componentes.json"

# === Carrega o JSON de configuração ===
if not os.path.isfile(ARQ_EXECUCAO):
    print(f"❌ Arquivo não encontrado: {ARQ_EXECUCAO}")
    exit(1)

with open(ARQ_EXECUCAO, "r", encoding="utf-8") as f:
    config_exec = json.load(f)

# Converte caminhos mesmo se vierem no formato /c/...
origem_base = path_gitbash_para_windows(config_exec.get("diretorioProjetosSF", ""))
destino_base = path_gitbash_para_windows(config_exec.get("diretorioAlteracaoCustomMtdLote", ""))

if not origem_base or not destino_base:
    print("❌ Caminhos 'diretorioProjetosSF' ou 'diretorioAlteracaoCustomMtdLote' ausentes ou inválidos.")
    exit(1)

backup_dir = os.path.join(destino_base, "bckp_preRet")
os.makedirs(backup_dir, exist_ok=True)

# === Carrega o JSON de mapeamento ===
if not os.path.isfile(ARQ_MAPA_PASTAS):
    print(f"❌ Arquivo não encontrado: {ARQ_MAPA_PASTAS}")
    exit(1)

with open(ARQ_MAPA_PASTAS, "r", encoding="utf-8") as f:
    mapa_pastas = json.load(f)

tipos_utilizados = [c.get("tipoComponente") for c in config_exec.get("componentes", [])]

# === Início do backup ===
timestamp = datetime.now().strftime("%Y%m%d-%H-%M")
print()
print(f"🚀 INÍCIO BACKUP: {timestamp}")
print(f"📂 Origem base : {origem_base}")
print(f"📁 Backup para : {backup_dir}")
print()

copiados = 0

for tipo in tipos_utilizados:
    subpasta = mapa_pastas.get(tipo)
    if not subpasta:
        print(f"⚠️ Tipo '{tipo}' não mapeado. Pulando...")
        continue

    pasta_origem = os.path.join(origem_base, subpasta)
    pasta_destino = os.path.join(backup_dir, subpasta)

    if not os.path.isdir(pasta_origem):
        print(f"⚠️ Pasta de origem não encontrada: {pasta_origem}")
        continue

    os.makedirs(pasta_destino, exist_ok=True)

    for root, _, files in os.walk(pasta_origem):
        for file in files:
            origem_path = os.path.join(root, file)
            caminho_relativo = os.path.relpath(origem_path, origem_base)
            destino_path = os.path.join(backup_dir, caminho_relativo)

            os.makedirs(os.path.dirname(destino_path), exist_ok=True)
            shutil.copy2(origem_path, destino_path)
            print(f"✅ Copiado: {caminho_relativo}")
            copiados += 1

# === Finalização ===
print()
if copiados == 0:
    print("⚠️ Nenhum arquivo foi copiado.")
else:
    print(f"🎉 Backup finalizado. Total de arquivos copiados: {copiados}")
    print(f"📦 Backup salvo em: {backup_dir}")

print(f"🏁 FIM: {datetime.now().strftime('%Y%m%d-%H-%M')}")
