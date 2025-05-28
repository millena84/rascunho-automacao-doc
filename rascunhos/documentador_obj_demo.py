# Script: gerador_struct_txt.py
# Autor: Jubileu (Salesforce Specialist)
# Descrição: Gera uma saída em formato texto (txt ou .tf) com o seguinte padrão:
# XXX\nfullName1: descricao1\nfullName2: descricao2\n...

import os
import xml.etree.ElementTree as ET
import json

# Carrega o mapeamento de pastas de componentes
with open('21_mapa_pastas_componentes.json', 'r', encoding='utf-8') as f:
    COMPONENT_MAP = json.load(f)

# Função para extrair fullName + descrição de campos de um objeto

def extrair_fullname_descricao(campos_path):
    dados = []
    ns = {'sf': 'http://soap.sforce.com/2006/04/metadata'}
    for nome_arquivo in os.listdir(campos_path):
        if nome_arquivo.endswith('.xml'):
            path = os.path.join(campos_path, nome_arquivo)
            tree = ET.parse(path)
            root = tree.getroot()
            fullName = root.findtext('sf:fullName', default='', namespaces=ns)
            descricao = root.findtext('sf:description', default='', namespaces=ns)
            if not descricao:
                descricao = root.findtext('sf:inlineHelpText', default='', namespaces=ns)
            dados.append((fullName, descricao.strip()))
    return dados

# Função principal

def gerar_txt_struct(config):
    base_path = config.get('basePath', '.')
    output_path = config.get('outputFile', './saida_struct.txt')
    objeto = config['customObject']

    campos_path = os.path.join(base_path, COMPONENT_MAP['CustomObject'], objeto, 'fields')
    pares = extrair_fullname_descricao(campos_path)

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("XXX\n")
        for fullName, descricao in pares:
            f.write(f"{fullName}: {descricao}\n")

    print(f"✅ Saída gerada: {output_path}")

# Execução
if __name__ == '__main__':
    with open('config_struct.json', 'r', encoding='utf-8') as f:
        config = json.load(f)
    gerar_txt_struct(config)
