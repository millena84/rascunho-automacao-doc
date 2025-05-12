import os
import shutil
import json
from datetime import datetime

# === Função robusta para converter caminhos estilo Git Bash para Windows ===
def path_gitbash_para_windows2(caminho):
    """
    Converte caminhos como /c/Users/... para C:/Users/... no Windows.
    Funciona mesmo com caminhos mistos e normaliza para o Python.
    """
    if caminho.startswith("/"):
        partes = caminho.strip("/").split("/", 1)
        if len(partes) == 2 and len(partes[0]) == 1:
            drive = partes[0].upper()
            resto = partes[1]
            return os.path.normpath(f"{drive}:/{resto}")
    return os.path.normpath(caminho)

def path_gitbash_para_windows(caminho):
    if caminho.startswith("/"):
        partes = caminho.strip("/").split("/", 1)
        if len(partes) == 2 and len(partes[0]) == 1:
            drive = partes[0].upper()
            resto = partes[1]
            return os.path.abspath(os.path.normpath(f"{drive}:/{resto}"))
    return os.path.abspath(os.path.normpath(caminho))


print(f"DEBUG | Caminho JSON origem (raw)   : {config_exec.get('diretorioProjetosSF')}")
print(f"DEBUG | Caminho convertido origem   : {origem_base}")
print(f"DEBUG | Existe origem?              : {os.path.isdir(origem_base)}")
print(f"DEBUG | Caminho destino convertido  : {destino_base}")
print(f"DEBUG | Caminho destino final       : {backup_dir}")


# === Arquivos de configuração ===
ARQ_EXECUCAO = "11_extract_org_metadata.json"
ARQ_MAPA_PASTAS = "21_mapa_pastas_componentes.json"

# === Carrega o JSON de execução ===
with open(ARQ_EXECUCAO, "r", encoding="utf-8") as f:
    config_exec = json.load(f)

origem_base = path_gitbash_para_windows(config_exec.get("diretorioProjetosSF", ""))
destino_base = path_gitbash_para_windows(config_exec.get("diretorioAlteracaoCustomMtdLote", ""))

if not os.path.isdir(origem_base):
    print(f"❌ Pasta de origem não encontrada: {origem_base}")
    print(f"❌ FIM EXECUCAO: {datetime.now().strftime('%Y%m%d-%H-%M')}")
    exit(1)

backup_dir = os.path.join(destino_base, "bckp_preRet")
os.makedirs(backup_dir, exist_ok=True)

# === Carrega mapeamento de pastas ===
with open(ARQ_MAPA_PASTAS, "r", encoding="utf-8") as f:
    mapa_pastas = json.load(f)

tipos_utilizados = [c.get("tipoComponente") for c in config_exec.get("componentes", [])]

# === Início do backup ===
timestamp = datetime.now().strftime("%Y%m%d-%H-%M")
print(f"\n🧃 INICIO PROCESSO BACKUP     {timestamp}")
print(f"📂 Origem: {origem_base}")
print(f"📁 Backup: {backup_dir}\n")

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
    print(f"🎉 Backup finalizado! Total de arquivos copiados: {copiados}")
    print(f"📦 Conteúdo salvo em: {backup_dir}")

print(f"✅ FIM EXECUCAO: {datetime.now().strftime('%Y%m%d-%H-%M')}")
