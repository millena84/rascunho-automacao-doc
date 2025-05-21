#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import shutil
import json
from datetime import datetime

# === Script python: 21_backup_pre_retrieve.py ===

# === Arquivos de configuração ===
ARQ_EXECUCAO = "/c/Users/mille/projetosSf/_configUtil.json"
ARQ_EXECUCAO_WIN = os.popen(f"cygpath -w {ARQ_EXECUCAO}").read().strip()
ARQ_MAPA_PASTAS = "21_mapa_pastas_compSf.json"

# === Função robusta para converter caminhos estilo Git-Bash para Windows ===
def path_gitbash_para_windows(caminho):
    if caminho.startswith("/"):
        partes = caminho.strip("/").split("/", 1)
        if len(partes) == 2 and len(partes[0]) == 1:
            drive = partes[0].upper()
            resto = partes[1]
            return os.path.abspath(os.path.normpath(f"{drive}:/{resto}"))
    return os.path.abspath(os.path.normpath(caminho))

# === Carrega JSON de execução ===
with open(ARQ_EXECUCAO_WIN, "r", encoding="utf-8") as f:
    config_exec = json.load(f)

# === Converte caminhos ===
retrieve_info = config_exec.get("infoEspecificaProcessos", {}).get("retrieve", [{}])[0]
origem_base = path_gitbash_para_windows(retrieve_info.get("dirPosixRef", ""))
destino_base = path_gitbash_para_windows(
    config_exec.get("infoEspecificaProcessos", {}).get("avaliacaoCustomMdt", [{}])[0]
    .get("infoCopiaLocal", {})
    .get("dirPosixCompPrincipal", "")
)
backup_dir = os.path.join(destino_base, "9_bckp_preRet")

timestamp = datetime.now().strftime("%d/%m/%Y - %H:%M:%S")
print(f"\n== INÍCIO PROCESSO: BACKUP - PASTAS DA '/force-app/main/default/': {timestamp}")
print(f" - Origem: {origem_base}")
print(f" - Destino: {backup_dir}\n")

# === Logs de verificação ===
print(f"🔵 Caminho origem JSON (raw)  : {retrieve_info.get('dirPosixRef', '')}")
print(f"🔵 Caminho origem convertido : {origem_base}")
print(f"🔵 Caminho destino JSON (raw): {destino_base}")
print(f"🔵 Caminho destino convertido: {backup_dir}\n")

if not os.path.isdir(origem_base):
    print(f"❌ Pasta de origem não encontrada: {origem_base}")
    print(f"❌ FIM EXECUÇÃO: {datetime.now().strftime('%d/%m/%Y - %H:%M:%S')}")
    exit(1)

os.makedirs(backup_dir, exist_ok=True)

# === Carrega mapeamento de pastas ===
with open(ARQ_MAPA_PASTAS, "r", encoding="utf-8") as f:
    mapa_pastas = json.load(f)

componentes = retrieve_info.get("infoRetrieveCustom", [])
tipos_utilizados = [c.get("tipoComponente") for c in componentes]

# === Início do backup ===
print(f"🟠 INÍCIO BACKUP: {timestamp}")
print(f"🟠 Origem: {origem_base}")
print(f"🟠 Destino: {backup_dir}\n")

copiados = 0

for tipo in tipos_utilizados:
    subpasta = mapa_pastas.get(tipo)
    if not subpasta:
        print(f"⚠️ Tipo '{tipo}' não mapeado. Pulando...")
        continue

    pasta_origem = os.path.join(origem_base, subpasta)
    pasta_destino = os.path.join(backup_dir, subpasta)

    if not os.path.isdir(pasta_origem):
        print(f"❌ Pasta de origem não encontrada: {pasta_origem}")
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
    print(f"✅ Backup finalizado! Total de arquivos copiados: {copiados}")
    print(f"✅ Conteúdo salvo em: {backup_dir}")

print(f"\n🟢 FIM EXECUÇÃO: {datetime.now().strftime('%d/%m/%Y - %H:%M:%S')}")
