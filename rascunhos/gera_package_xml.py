#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import json
from datetime import datetime

# === CONFIGURAÇÕES ===
CONFIG_PATH = "/c/Users/mille/projetosSf/_configUtil.json"
PASTA_CSV = "./1_metadados"
ARQUIVO_XML_FINAL = "./21_packageForRetrieve.xml"
ARQUIVO_XML_VERSIONADO = f"./_retrieves/{datetime.now().strftime('%Y%m%d-%H%M%S')}_21_packageForRetrieve.xml"
API_VERSION = "58.0"

# === Função: conversor Git Bash para Windows ===
def normalizar_caminho(caminho):
    if caminho.startswith("/"):
        partes = caminho.strip("/").split("/", 1)
        if len(partes) == 2 and len(partes[0]) == 1:
            return os.path.abspath(f"{partes[0].upper()}:/{partes[1]}")
    return os.path.abspath(caminho)

# === Lê JSON de configuração ===
with open(CONFIG_PATH, "r", encoding="utf-8") as f:
    config = json.load(f)

componentes = (
    config.get("infoEspecificaProcessos", {})
    .get("retrieve", [{}])[0]
    .get("infoRetrieveCustom", [])
)

if not componentes:
    print("❌ Nenhum componente encontrado no JSON.")
    exit(1)

# === Cria pasta de saída ===
os.makedirs("./_retrieves", exist_ok=True)

# === Início do XML ===
with open(ARQUIVO_XML_FINAL, "w", encoding="utf-8") as xml:
    xml.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    xml.write('<Package xmlns="http://soap.sforce.com/2006/04/metadata">\n')

    for comp in componentes:
        tipo = comp.get("tipoComponente")
        if not tipo:
            continue

        tipo_lower = tipo.lower()
        csv_path = os.path.join(PASTA_CSV, f"_Extracao_{tipo_lower}.csv")

        if not os.path.isfile(csv_path):
            print(f"⚠️  Tipo '{tipo}' não encontrado em {PASTA_CSV}. Pulando.")
            continue

        xml.write("  <types>\n")
        with open(csv_path, "r", encoding="utf-8") as csv_file:
            for linha in csv_file:
                membro = linha.strip()
                if membro:
                    xml.write(f"    <members>{membro}</members>\n")
        xml.write(f"    <name>{tipo}</name>\n")
        xml.write("  </types>\n")

    xml.write(f"  <version>{API_VERSION}</version>\n")
    xml.write("</Package>\n")

# === Salva versão do XML ===
shutil.copy2(ARQUIVO_XML_FINAL, ARQUIVO_XML_VERSIONADO)

print(f"✅ XML gerado com sucesso: {ARQUIVO_XML_FINAL}")
print(f"📁 Cópia versionada salva em: {ARQUIVO_XML_VERSIONADO}")
