# Script principal para gerar os arquivos CSV com base nos metadados XML e JSON
# Requisitos: Python 3.x (sem dependências externas além de os, json, xml)

import os
import json
import xml.etree.ElementTree as ET
import csv

# === Funções utilitárias ===

def carregar_json(caminho):
    with open(caminho, 'r', encoding='utf-8') as f:
        return json.load(f)

def salvar_csv(caminho_csv, cabecalho, dados):
    with open(caminho_csv, mode='w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(cabecalho)
        writer.writerows(dados)

def path_gitbash_para_windows(caminho):
    if caminho.startswith("/"):
        partes = caminho.strip("/").split("/", 1)
        if len(partes) == 2 and len(partes[0]) == 1:
            drive = partes[0].upper()
            resto = partes[1]
            return os.path.abspath(os.path.normpath(f"{drive}:/" + resto))
    return os.path.abspath(os.path.normpath(caminho))

def buscar_tag(root, tag):
    return root.findtext(tag) or ''

def buscar_bool(root, tag):
    return root.findtext(tag) == 'true'

# === Função principal ===

def processar_objetos(json_entity_path, pasta_raiz, pasta_saida):
    os.makedirs(pasta_saida, exist_ok=True)

    # Arquivos de saída e cabeçalhos
    arquivos = {
        'S1': ("S1_objeto.csv", ["label", "fullName", "enableFeeds", "enableHistory"]),
        'S2': ("S2_objeto_campos.csv", ["label object", "fullName object", "fieldLabel", "fieldFullName", "fieldTrackFeedHistory", "fieldTrackHistory"]),
        'S3': ("S3_permission_sets.csv", ["label object", "fullName object", "permissionSetLabel", "permissionSetFullName", "allowCreate", "allowDelete", "allowEdit", "allowRead", "modifyAllRecords", "viewAllFields", "viewAllRecords"]),
        'S4': ("S4_profiles.csv", ["label object", "fullName object", "profileLabel", "profileFullName", "allowCreate", "allowDelete", "allowEdit", "allowRead", "modifyAllRecords", "viewAllFields", "viewAllRecords"]),
        'S5': ("S5_field_permissions_permissionsets.csv", ["label object", "fullName object", "fieldLabel", "fieldFullName", "PermissionSetLabel", "permissionSetFullName", "editable", "visible", "available"]),
        'S6': ("S6_field_permissions_profiles.csv", ["label object", "fullName object", "fieldLabel", "fieldFullName", "profileLabel", "profileFullName", "editable", "visible", "available"]),
    }

    saidas = {chave: [] for chave in arquivos.keys()}

    dados = carregar_json(json_entity_path)
    registros = dados['result']['records']

    for reg in registros:
        api = reg['QualifiedApiName']
        label_obj = reg['Label']
        pasta_obj = os.path.join(pasta_raiz, 'objects', api)
        arq_obj = os.path.join(pasta_obj + f".object-meta.xml")

        if os.path.exists(arq_obj):
            tree = ET.parse(arq_obj)
            root = tree.getroot()
            label = buscar_tag(root, 'label')
            enableFeeds = buscar_tag(root, 'enableFeeds')
            enableHistory = buscar_tag(root, 'enableHistory')
            saidas['S1'].append([label, api, enableFeeds, enableHistory])

            nameField = root.find('nameField')
            if nameField is not None:
                name_label = buscar_tag(nameField, 'label')
                name_trackFeed = buscar_tag(nameField, 'trackFeedHistory')
                name_trackHist = buscar_tag(nameField, 'trackHistory')
                saidas['S2'].append([label, api, name_label, 'Name', name_trackFeed, name_trackHist])

        # Campos do objeto
        pasta_fields = os.path.join(pasta_raiz, 'objects', api, 'fields')
        if os.path.exists(pasta_fields):
            for file in os.listdir(pasta_fields):
                if file.endswith('.field-meta.xml'):
                    tree = ET.parse(os.path.join(pasta_fields, file))
                    root = tree.getroot()
                    fieldLabel = buscar_tag(root, 'label')
                    fieldFullName = buscar_tag(root, 'fullName')
                    trackFeed = buscar_tag(root, 'trackFeedHistory')
                    trackHist = buscar_tag(root, 'trackHistory')
                    saidas['S2'].append([label_obj, api, fieldLabel, fieldFullName, trackFeed, trackHist])

    # Exportar os CSVs
    for chave, (nome_arquivo, cabecalho) in arquivos.items():
        salvar_csv(os.path.join(pasta_saida, nome_arquivo), cabecalho, saidas[chave])

    print(f"✅ Arquivos CSV gerados na pasta: {pasta_saida}")

# === Execução exemplo ===
if __name__ == "__main__":
    # Exemplo de caminhos (ajuste conforme seu ambiente)
    JSON_ENTITY_PATH = "./result_entityDefinition.json"
    PASTA_RAIZ = "/CAMINHO/DO/SEU/PROJETO"  # substitua pelo caminho correto do seu projeto
    PASTA_SAIDA = "./saida_csv"

    processar_objetos(JSON_ENTITY_PATH, PASTA_RAIZ, PASTA_SAIDA)
