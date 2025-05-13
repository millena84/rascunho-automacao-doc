import os
import csv
import xml.etree.ElementTree as ET

# Namespace padrão da Metadata API do Salesforce
SF_NAMESPACE = 'http://soap.sforce.com/2006/04/metadata'
ET.register_namespace('', SF_NAMESPACE)

def gerar_custom_metadata(nome_arquivo, label, canal, formato, pasta_destino='./saida_xml'):
    os.makedirs(pasta_destino, exist_ok=True)

    root = ET.Element(f'{{{SF_NAMESPACE}}}CustomMetadata')

    ET.SubElement(root, f'{{{SF_NAMESPACE}}}label').text = label
    ET.SubElement(root, f'{{{SF_NAMESPACE}}}protected').text = 'false'

    canal_val = ET.SubElement(root, f'{{{SF_NAMESPACE}}}values')
    ET.SubElement(canal_val, f'{{{SF_NAMESPACE}}}field').text = 'Canal__c'
    ET.SubElement(canal_val, f'{{{SF_NAMESPACE}}}value').text = f'<string>{canal}</string>'

    formato_val = ET.SubElement(root, f'{{{SF_NAMESPACE}}}values')
    ET.SubElement(formato_val, f'{{{SF_NAMESPACE}}}field').text = 'Formato__c'
    ET.SubElement(formato_val, f'{{{SF_NAMESPACE}}}value').text = f'<string>{formato}</string>'

    caminho_saida = os.path.join(pasta_destino, f'{nome_arquivo}')
    ET.ElementTree(root).write(caminho_saida, encoding='utf-8', xml_declaration=True)
    print(f'✅ XML gerado: {caminho_saida}')

def processar_csv_entrada(caminho_csv):
    with open(caminho_csv, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter=';')
        for i, linha in enumerate(reader):
            label = linha['label']
            canal = linha['Canal']
            formato = linha['Formato']
            nome_arquivo = f"{label.replace('.', '_').replace('-', '_')}.md-meta.xml"

            gerar_custom_metadata(
                nome_arquivo=nome_arquivo,
                label=label,
                canal=canal,
                formato=formato
            )

# 🔁 Chamada principal:
processar_csv_entrada('./3_saida_csv/2_listaVinculosPrecisamCustom.csv')
