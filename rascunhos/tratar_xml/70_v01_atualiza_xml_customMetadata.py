###
# SCRIPT 1 - Atualiza XML via ElementTree (arquivo separado)
# Salve como: atualizar_elementtree.py
###

import os
import csv
import xml.etree.ElementTree as ET

CAMINHO_CSV = './3_saida_csv/1_listaCustomAlteracao.csv'
PASTA_XML_ORIGEM = './2_entrada_xml'
PASTA_XML_SAIDA = './4_xml_corrigido_elementtree'
NAMESPACE = 'http://soap.sforce.com/2006/04/metadata'
ET.register_namespace('', NAMESPACE)

def corrigir_elementtree(xml_path, canal, formato, destino):
    tree = ET.parse(xml_path)
    root = tree.getroot()

    for values in root.findall(f'.//{{{NAMESPACE}}}values'):
        field = values.find(f'{{{NAMESPACE}}}field')
        value = values.find(f'{{{NAMESPACE}}}value')
        if field is not None and value is not None:
            if field.text.strip() == 'Canal__c':
                value.text = canal.strip()
            elif field.text.strip() == 'Formato__c':
                value.text = formato.strip()

    os.makedirs(os.path.dirname(destino), exist_ok=True)
    tree.write(destino, encoding='utf-8', xml_declaration=True)

def processar_csv():
    with open(CAMINHO_CSV, newline='', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f, delimiter=';')
        for row in reader:
            nome = row['Arquivo'].strip()
            canal = row['CANAL_TABELA'].strip()
            formato = row['FORMATO_TABELA'].strip()

            entrada = os.path.join(PASTA_XML_ORIGEM, nome)
            saida = os.path.join(PASTA_XML_SAIDA, nome)

            if os.path.exists(entrada):
                corrigir_elementtree(entrada, canal, formato, saida)
                print(f'✅ Atualizado via ElementTree: {nome}')
            else:
                print(f'❌ Arquivo não encontrado: {nome}')

if __name__ == '__main__':
    processar_csv()
