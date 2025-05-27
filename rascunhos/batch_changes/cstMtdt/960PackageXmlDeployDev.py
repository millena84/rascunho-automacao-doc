#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import shutil
import json
import csv
from datetime import datetime

# === CONFIGURAÇÕES ===
CONFIG_PATH = "_configUtil.json"
API_VERSION = "58.0"

# === Função: conversor Git Bash → Windows ===
def conversao_path_posix_para_windows(caminho):
    if caminho.startswith("/"):
        partes = caminho.strip("/").split("/", 1)
        if len(partes) == 2 and len(partes[0]) == 1:
            return os.path.abspath(os.path.normpath(f"{partes[0].upper()}:/{partes[1]}"))
    return os.path.abspath(os.path.normpath(caminho))

# === Leitura do JSON ===
with open(CONFIG_PATH, "r", encoding="utf-8") as f:
    config = json.load(f)

DIR_PROJETOS_VSCODE = config.get("dirPosixRepoVscode", "")
DIR_PROJSF_TRABALHO_CUSTOM = (
    config.get("infoEspecificaProcessos", {})
    .get("avaliacaoCustomMdt", [{}])[0]
    .get("dirProjSfCustom", "")
)
DIR_COMPLETO_PROJETOSF_TRABALHO_CUSTOM = os.path.join(
    DIR_PROJETOS_VSCODE, DIR_PROJSF_TRABALHO_CUSTOM
)

# === Caminho das pastas com CSVs ===
DIR_CRIADOS = os.path.join(DIR_COMPLETO_PROJETOSF_TRABALHO_CUSTOM, "processaCmdt", "3_saida_xml", "criados")
DIR_ALTERADOS = os.path.join(DIR_COMPLETO_PROJETOSF_TRABALHO_CUSTOM, "processaCmdt", "3_saida_xml", "alterados")

# === Caminho do arquivo final ===
ARQUIVO_XML_FINAL = os.path.join(
    DIR_COMPLETO_PROJETOSF_TRABALHO_CUSTOM,
    "processaCmdt",
    "PackageParaDeployCmdt.xml"
)

# === Função auxiliar: leitura de arquivos CSV ===
def extrair_componentes_dos_csvs(diretorio):
    tipos = {}
    if not os.path.isdir(diretorio):
        print(f"⚠️ Pasta não encontrada: {diretorio}")
        return tipos

    for nome_arquivo in os.listdir(diretorio):
        if nome_arquivo.endswith(".csv"):
            caminho_arquivo = os.path.join(diretorio, nome_arquivo)
            with open(caminho_arquivo, "r", encoding="utf-8") as csv_file:
                for linha in csv_file:
                    membro = linha.strip()
                    if not membro or "," not in membro:
                        continue
                    tipo, nome = membro.split(",", 1)
                    tipo = tipo.strip()
                    nome = nome.strip()
                    if tipo and nome:
                        tipos.setdefault(tipo, set()).add(nome)
    return tipos

# === Leitura dos componentes das duas pastas ===
componentes_criados = extrair_componentes_dos_csvs(DIR_CRIADOS)
componentes_alterados = extrair_componentes_dos_csvs(DIR_ALTERADOS)

# === Mescla dos componentes ===
todos_componentes = {}
for tipo_dict in [componentes_criados, componentes_alterados]:
    for tipo, membros in tipo_dict.items():
        todos_componentes.setdefault(tipo, set()).update(membros)

if not todos_componentes:
    print("❌ Nenhum componente encontrado nas pastas 'criados' ou 'alterados'.")
    exit()

# === Geração do XML ===
with open(ARQUIVO_XML_FINAL, "w", encoding="utf-8") as xml:
    xml.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    xml.write('<Package xmlns="http://soap.sforce.com/2006/04/metadata">\n')

    for tipo, membros in sorted(todos_componentes.items()):
        xml.write("  <types>\n")
        for membro in sorted(membros):
            xml.write(f"    <members>{membro}</members>\n")
        xml.write(f"    <name>{tipo}</name>\n")
        xml.write("  </types>\n")

    xml.write(f"  <version>{API_VERSION}</version>\n")
    xml.write("</Package>\n")

print(f"✅ XML gerado com sucesso: {ARQUIVO_XML_FINAL}")
