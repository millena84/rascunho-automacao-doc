#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import csv
import json
from datetime import datetime
from difflib import SequenceMatcher

# === Função para converter caminhos estilo Git Bash para Windows ===
def path_gitbash_para_windows(caminho):
    if caminho.startswith("/"):
        partes = caminho.strip("/").split("/", 1)
        if len(partes) == 2 and len(partes[0]) == 1:
            drive = partes[0].upper()
            resto = partes[1]
            return os.path.abspath(os.path.normpath(f"{drive}:/{resto}"))
    return os.path.abspath(os.path.normpath(caminho))

# === Leitura do JSON de entrada ===
ARQ_EXECUCAO = '_configUtil.json'

with open(ARQ_EXECUCAO, "r", encoding="utf-8") as f:
    config = json.load(f)

# === Leitura dos diretórios ===
DIR_PROJETOS_VSCODE = config.get("infoVscode", [{}])[0].get("dirPosixRepoVscode", "")
DIR_PROJSF_TRABALHO_CUSTOM = config.get("infoEspecificaProcessos", {}).get("avaliacaoCustomMdt", [{}])[0].get("dirProjSfCustom", "")
DIR_PROCESSO_CUSTOM = config.get("infoEspecificaProcessos", {}).get("avaliacaoCustomMdt", [{}])[0].get("nmdirProcessoCmdt", "")

# === Monta os caminhos absolutos ===
diretorio_base = path_gitbash_para_windows(f"{DIR_PROJETOS_VSCODE}{DIR_PROJSF_TRABALHO_CUSTOM}")
diretorio_metadados = os.path.join(diretorio_base, DIR_PROCESSO_CUSTOM, "_1_metadados")
diretorio_saida = os.path.join(diretorio_base, DIR_PROCESSO_CUSTOM, "_3_saida_xml")

arquivo_entrada = os.path.join(diretorio_metadados, "_DadoCustomMetadata_ref.csv")
arquivo_custom = os.path.join(diretorio_metadados, "_InfoParametrizadasInclCustom.csv")
arquivo_alteracao = os.path.join(diretorio_saida, "1_listaCustomAlteracao.csv")
arquivo_criacao = os.path.join(diretorio_saida, "1_listavinculosPrecisamCustom.csv")
arquivo_sem_alteracao = os.path.join(diretorio_saida, "CustomSemAlteracao.csv")
arquivo_sem_param = os.path.join(diretorio_saida, "CustomSemParam.csv")
arquivo_estatisticas = os.path.join(diretorio_saida, "estatisticas_comparacao.txt")

os.makedirs(diretorio_saida, exist_ok=True)

print(f"📄 Comparando arquivos: {arquivo_entrada} vs {arquivo_custom}\n")

def limpar(texto):
    if texto is None:
        return ''
    return str(texto).strip().replace('\n', ' ').replace('\r', ' ')

def similaridade(a, b):
    return SequenceMatcher(None, a, b).ratio()

with open(arquivo_entrada, 'r', encoding='utf-8-sig') as f_ref, \
     open(arquivo_custom, 'r', encoding='utf-8-sig') as f_custom:

    linhas_ref = list(csv.reader(f_ref))
    linhas_custom = list(csv.reader(f_custom))

cabecalho = linhas_ref[0]
ref_dict = {linha[0]: linha for linha in linhas_ref[1:] if "RDC" not in linha[0].upper()}
custom_dict = {linha[0]: linha for linha in linhas_custom}

alteracoes = []
sem_alteracao = []
sem_param = []

for nome_arquivo, ref_valores in ref_dict.items():
    custom_valores = custom_dict.get(nome_arquivo)
    if not custom_valores:
        sem_param.append(ref_valores)
        continue

    campos_diferentes = []
    for i in range(1, len(ref_valores)):
        ref_campo = limpar(ref_valores[i])
        custom_campo = limpar(custom_valores[i])
        if ref_campo != custom_campo:
            sim = similaridade(ref_campo, custom_campo)
            if sim < 0.9:
                campos_diferentes.append((cabecalho[i], ref_campo, custom_campo, f"{sim:.2f}"))

    if campos_diferentes:
        print(f"\n🔁 Diferenças encontradas em: {nome_arquivo}")
        for campo, ref, custom, sim in campos_diferentes:
            print(f" - Campo: {campo}\n   REF   : {ref}\n   CUSTOM: {custom}\n   Similaridade: {sim}")

        resp = input("Deseja registrar como ALTERAÇÃO? (s/n): ").strip().lower()
        if resp == 's':
            alteracoes.append(ref_valores)
        else:
            sem_alteracao.append(ref_valores)
    else:
        sem_alteracao.append(ref_valores)

# === Escrita dos arquivos ===
with open(arquivo_alteracao, 'w', newline='', encoding='utf-8-sig') as f:
    writer = csv.writer(f)
    writer.writerow(cabecalho)
    writer.writerows(alteracoes)

with open(arquivo_sem_alteracao, 'w', newline='', encoding='utf-8-sig') as f:
    writer = csv.writer(f)
    writer.writerow(cabecalho)
    writer.writerows(sem_alteracao)

with open(arquivo_criacao, 'w', newline='', encoding='utf-8-sig') as f:
    writer = csv.writer(f)
    writer.writerow(cabecalho)
    writer.writerows(sem_param)

with open(arquivo_estatisticas, 'w', encoding='utf-8') as f:
    f.write(f"# Estatísticas da comparação ({datetime.now().strftime('%Y-%m-%d %H:%M:%S')})\n")
    f.write(f"Total analisados: {len(ref_dict)}\n")
    f.write(f"Com alteração: {len(alteracoes)}\n")
    f.write(f"Sem alteração: {len(sem_alteracao)}\n")
    f.write(f"Sem parâmetro custom: {len(sem_param)}\n")

print("\n✅ Comparação finalizada.")
print(f"✏️ Alterações registradas : {len(alteracoes)}")
print(f"✔️ Sem alteração          : {len(sem_alteracao)}")
print(f"📭 Sem parâmetro (custom) : {len(sem_param)}")
