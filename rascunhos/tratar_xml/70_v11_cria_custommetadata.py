
import os 
import csv 
import xml.etree.ElementTree as ET

Diretórios ajustáveis:

CSV_ENTRADA = './3_saida_csv/2_listaVinculosPrecisamCustom.csv'  # CSV com campos: label;CampoRelacionamentoObjetoFilho;...;Canal;Formato;... PASTA_SAIDA = './5_xml_novos_elementtree'                         # Para onde salvar os XMLs gerados NAMESPACE = 'http://soap.sforce.com/2006/04/metadata' ET.register_namespace('', NAMESPACE)

def criar_custom_metadata(label, canal, formato, nome_arquivo): root = ET.Element('CustomMetadata', xmlns=NAMESPACE)

ET.SubElement(root, 'label').text = label
ET.SubElement(root, 'protected').text = 'false'

v1 = ET.SubElement(root, 'values')
ET.SubElement(v1, 'field').text = 'Canal__c'
ET.SubElement(v1, 'value').text = canal

v2 = ET.SubElement(root, 'values')
ET.SubElement(v2, 'field').text = 'Formato__c'
ET.SubElement(v2, 'value').text = formato

os.makedirs(PASTA_SAIDA, exist_ok=True)
destino = os.path.join(PASTA_SAIDA, nome_arquivo)
tree = ET.ElementTree(root)
tree.write(destino, encoding='utf-8', xml_declaration=True)
print(f'✅ Criado via ElementTree: {nome_arquivo}')

def processar_csv(): with open(CSV_ENTRADA, newline='', encoding='utf-8-sig') as f: reader = csv.DictReader(f, delimiter=';') contador = 1

for row in reader:
        canal = row['Canal'].strip()
        formato = row['Formato'].strip()
        label = row['label'].strip()
        nome_arquivo = f'CamposCanalFormato.{formato.upper()}{contador:03}.md-meta.xml'
        criar_custom_metadata(label, canal, formato, nome_arquivo)
        contador += 1

if name == 'main': processar_csv()

