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
            return os.path.abspath(os.path.normpath(f"{drive}:/{resto}"))
    return os.path.abspath(os.path.normpath(caminho))

def join_posix_path(*partes):
    return '/'.join(str(p).strip('/') for p in partes if p).join(['/', '']) if partes and str(partes[0]).startswith('/') else '/'.join(str(p).strip('/') for p in partes if p)

def buscar_tag(root, tag):
    namespaces = {'ns': root.tag.split('}')[0].strip('{')} if '}' in root.tag else {}
    elem = root.find(f'.//ns:{tag}', namespaces) if namespaces else root.find(tag)
    txt = elem.text.strip() if elem is not None and elem.text else ''
    if not txt:
        return 'false' if 'track' in tag.lower() else ''
    return txt

def buscar_tag_direta(elemento, tag):
    ns = {'ns': elemento.tag.split('}')[0].strip('{')} if '}' in elemento.tag else {}
    elem = elemento.find(f'ns:{tag}', ns) if ns else elemento.find(tag)
    txt = elem.text.strip() if elem is not None and elem.text else ''
    return txt

# === Leitura de permissões ===
def processar_permissoes(pasta_raiz, mapa_labels_objetos, mapa_labels_campos, saidas):
    for tipo, pasta, chave_csv_obj, chave_csv_field in [
        ('PermissionSet', 'permissionsets', 'S3', 'S5'),
        ('Profile', 'profiles', 'S4', 'S6')
    ]:
        pasta_completa = path_gitbash_para_windows(join_posix_path(pasta_raiz, pasta))
        if not os.path.exists(pasta_completa):
            continue

        for arq in os.listdir(pasta_completa):
            if not arq.endswith('.xml'):
                continue
            caminho = os.path.join(pasta_completa, arq)
            try:
                tree = ET.parse(caminho)
                root = tree.getroot()
                ns = {'ns': root.tag.split('}')[0].strip('{')} if '}' in root.tag else {}
                nome_perm = arq.replace('.xml', '')

                for perm in root.findall('.//ns:objectPermissions', ns):
                    obj = buscar_tag_direta(perm, 'object')
                    if not obj:
                        continue
                    label_obj = mapa_labels_objetos.get(obj, obj)
                    linha = [
                        label_obj, obj, nome_perm, nome_perm,
                        buscar_tag_direta(perm, 'allowCreate'),
                        buscar_tag_direta(perm, 'allowDelete'),
                        buscar_tag_direta(perm, 'allowEdit'),
                        buscar_tag_direta(perm, 'allowRead'),
                        buscar_tag_direta(perm, 'modifyAllRecords'),
                        buscar_tag_direta(perm, 'viewAllFields'),
                        buscar_tag_direta(perm, 'viewAllRecords')
                    ]
                    saidas[chave_csv_obj].append(linha)

                for perm in root.findall('.//ns:fieldPermissions', ns):
                    campo = buscar_tag_direta(perm, 'field')
                    if '.' not in campo:
                        continue
                    obj, campo_api = campo.split('.', 1)
                    label_obj = mapa_labels_objetos.get(obj, obj)
                    label_campo = mapa_labels_campos.get(campo, campo_api)
                    linha = [
                        label_obj, obj, label_campo, campo, nome_perm, nome_perm,
                        buscar_tag_direta(perm, 'editable'), buscar_tag_direta(perm, 'readable'), 'true'
                    ]
                    saidas[chave_csv_field].append(linha)
            except Exception as e:
                print(f"⚠️ Erro ao processar {tipo} {arq}: {e}")

# === Função principal ===
def processar_objetos(json_entity_path, pasta_raiz, pasta_saida):
    os.makedirs(pasta_saida, exist_ok=True)

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

    mapa_labels_objetos = {}
    mapa_labels_campos = {}

    for reg in registros:
        api = reg['QualifiedApiName']
        label_obj = reg['Label']
        print(f"🔍 Processando objeto: {api} - {label_obj}")

        mapa_labels_objetos[api] = label_obj
        pasta_obj = join_posix_path(pasta_raiz, 'objects', api)
        arq_obj = join_posix_path(pasta_obj, api + ".object-meta.xml")
        arq_obj = path_gitbash_para_windows(arq_obj)

        encontrou_objeto = False

        if os.path.exists(arq_obj):
            tree = ET.parse(arq_obj)
            root = tree.getroot()
            label = buscar_tag(root, 'label')
            enableFeeds = buscar_tag(root, 'enableFeeds')
            enableHistory = buscar_tag(root, 'enableHistory')
            saidas['S1'].append([label or label_obj, api, enableFeeds, enableHistory])
            encontrou_objeto = True

            nameField = root.find('.//nameField')
            if nameField is not None:
                name_label = buscar_tag(nameField, 'label')
                name_trackFeed = buscar_tag(nameField, 'trackFeedHistory')
                name_trackHist = buscar_tag(nameField, 'trackHistory')
                saidas['S2'].append([label or label_obj, api, name_label, 'Name', name_trackFeed, name_trackHist])

        pasta_fields = join_posix_path(pasta_raiz, 'objects', api, 'fields')
        pasta_fields = path_gitbash_para_windows(pasta_fields)
        if os.path.exists(pasta_fields):
            for file in os.listdir(pasta_fields):
                if file.endswith('.field-meta.xml'):
                    caminho_completo = os.path.join(pasta_fields, file)
                    tree = ET.parse(caminho_completo)
                    root = tree.getroot()
                    fieldLabel = buscar_tag(root, 'label')
                    fieldFullName = buscar_tag(root, 'fullName')
                    trackFeed = buscar_tag(root, 'trackFeedHistory') or 'false'
                    trackHist = buscar_tag(root, 'trackHistory') or 'false'
                    saidas['S2'].append([label_obj, api, fieldLabel, fieldFullName, trackFeed, trackHist])
                    mapa_labels_campos[f"{api}.{fieldFullName}"] = fieldLabel
                    encontrou_objeto = True

        if not encontrou_objeto:
            saidas['S1'].append([label_obj, api, '', ''])

    # Leitura de permissões
    processar_permissoes(pasta_raiz, mapa_labels_objetos, mapa_labels_campos, saidas)

    for chave, (nome_arquivo, cabecalho) in arquivos.items():
        caminho_csv = join_posix_path(pasta_saida, nome_arquivo)
        caminho_csv = path_gitbash_para_windows(caminho_csv)
        salvar_csv(caminho_csv, cabecalho, saidas[chave])
        print(f"✅ CSV salvo: {caminho_csv} ({len(saidas[chave])} registros)")

    print(f"🎉 Processamento finalizado. Arquivos CSV gerados em: {pasta_saida}")

# Execução usando _configUtil.json
if __name__ == "__main__":
    JSON_CONFIG = "./_configUtil.json"

    with open(JSON_CONFIG, 'r', encoding='utf-8') as f:
        CONFIG = json.load(f)

    PASTA_PROJSF = CONFIG.get('consultasTabelasInternas', {}).get('consultaEntityDefinition', {}).get('dirPosixProjSf')
    print(f"📂 Pasta do projeto: {PASTA_PROJSF}")

    PASTA_PROJSF = f'{PASTA_PROJSF}/force-app/main/default'

    PASTA_RESULT = CONFIG.get('consultasTabelasInternas', {}).get('consultaEntityDefinition', {}).get('dirSaidaCompleto')
    print(f"📂 Pasta de resultados: {PASTA_RESULT}")

    ARQ_RESULT = CONFIG.get('consultasTabelasInternas', {}).get('consultaEntityDefinition', {}).get('arquivoSaida')
    print(f"📄 Arquivo de resultados: {ARQ_RESULT}")

    DIR_RESULT_COMPLETO = f'{PASTA_RESULT}/{ARQ_RESULT}'
    print(f"📄 Caminho completo do arquivo de resultados: {DIR_RESULT_COMPLETO}")

    DIR_RESULT_COMPLETO = path_gitbash_para_windows(DIR_RESULT_COMPLETO)
    print(f"📄 Caminho completo do arquivo de resultados (Windows): {DIR_RESULT_COMPLETO}")

    PASTA_SAIDA = PASTA_RESULT
    os.makedirs(PASTA_SAIDA, exist_ok=True)

    processar_objetos(DIR_RESULT_COMPLETO, PASTA_PROJSF, PASTA_SAIDA)
