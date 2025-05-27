#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import json

# === CONFIGURAÇÕES ===
CONFIG_PATH = "_configUtil.json"
API_VERSION = "58.0"
TIPO_COMPONENTE = "CustomMetadata"

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

# === Caminhos das pastas de entrada ===
DIR_CRIADOS = os.path.join(DIR_COMPLETO_PROJETOSF_TRABALHO_CUSTOM, "processaCmdt", "3_saida_xml", "criados")
DIR_ALTERADOS = os.path.join(DIR_COMPLETO_PROJETOSF_TRABALHO_CUSTOM, "processaCmdt", "3_saida_xml", "alterados")

# === Caminho de saída ===
ARQUIVO_XML_FINAL = os.path.join(
    DIR_COMPLETO_PROJETOSF_TRABALHO_CUSTOM,
    "processaCmdt",
    "PackageParaDeployCmdt.xml"
)

# === Função para extrair nomes de arquivos XML ===
def extrair_nomes_xml(diretorio):
    nomes = set()
    if not os.path.isdir(diretorio):
        print(f"⚠️ Pasta não encontrada: {diretorio}")
        return nomes

    for nome_arquivo in os.listdir(diretorio):
        if nome_arquivo.endswith("-meta.xml"):
            nome = nome_arquivo.replace("-meta.xml", "")
            nomes.add(nome)
    return nomes

# === Coleta os nomes dos componentes ===
componentes_criados = extrair_nomes_xml(DIR_CRIADOS)
componentes_alterados = extrair_nomes_xml(DIR_ALTERADOS)

# === Unifica todos os nomes ===
todos_membros = sorted(componentes_criados.union(componentes_alterados))

if not todos_membros:
    print("❌ Nenhum componente encontrado nas pastas de entrada.")
    exit()

# === Geração do package.xml ===
with open(ARQUIVO_XML_FINAL, "w", encoding="utf-8") as xml:
    xml.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    xml.write('<Package xmlns="http://soap.sforce.com/2006/04/metadata">\n')
    xml.write("  <types>\n")
    for membro in todos_membros:
        xml.write(f"    <members>{membro}</members>\n")
    xml.write(f"    <name>{TIPO_COMPONENTE}</name>\n")
    xml.write("  </types>\n")
    xml.write(f"  <version>{API_VERSION}</version>\n")
    xml.write("</Package>\n")

print(f"✅ Package gerado com sucesso com {len(todos_membros)} componentes.")
print(f"📦 Caminho: {ARQUIVO_XML_FINAL}")
