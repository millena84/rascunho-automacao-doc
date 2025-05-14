###
# SCRIPT 1 - Atualiza XML via ElementTree (pode quebrar estrutura visual do XML)
# Diretórios ajustáveis:
# - CAMINHO_CSV = caminho para o CSV com colunas: Arquivo;CANAL_TABELA;FORMATO_TABELA
# - PASTA_XML_ORIGEM = onde estão os XMLs de entrada
# - PASTA_XML_SAIDA = para onde vão os XMLs corrigidos
###

import os
import csv
import xml.etree.ElementTree as ET
import re

CAMINHO_CSV = './3_saida_csv/1_listaCustomAlteracao.csv'  # Ajuste conforme sua estrutura
PASTA_XML_ORIGEM = './2_entrada_xml'                       # Ajuste conforme sua estrutura
PASTA_XML_SAIDA_ELEMENTTREE = './4_xml_corrigido_elementtree'  # Estrutura modificada
PASTA_XML_SAIDA_REGEX = './4_xml_corrigido_regex'          # Novo para o script 2

NAMESPACE = 'http://soap.sforce.com/2006/04/metadata'
ET.register_namespace('', NAMESPACE)

###
# SCRIPT 1 - ElementTree (não recomendado se quiser manter estrutura)
###
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


###
# SCRIPT 2 - Regex preservando estrutura do XML (recomendado)
###
def corrigir_regex(xml_path, canal, formato, destino):
    with open(xml_path, 'r', encoding='utf-8') as f:
        conteudo = f.read()

    canal_regex = re.compile(
        r'(<values>\s*<field>\s*Canal__c\s*</field>\s*<value[^>]*>)(.*?)(</value>\s*</values>)',
        re.DOTALL | re.IGNORECASE
    )
    formato_regex = re.compile(
        r'(<values>\s*<field>\s*Formato__c\s*</field>\s*<value[^>]*>)(.*?)(</value>\s*</values>)',
        re.DOTALL | re.IGNORECASE
    )

    conteudo, canal_count = canal_regex.subn(rf'\1{canal}\3', conteudo)
    conteudo, formato_count = formato_regex.subn(rf'\1{formato}\3', conteudo)

    if canal_count == 0 or formato_count == 0:
        print(f'❌ NÃO ENCONTRADO Canal__c ou Formato__c em {os.path.basename(xml_path)}')
        return

    os.makedirs(os.path.dirname(destino), exist_ok=True)
    with open(destino, 'w', encoding='utf-8', newline='\n') as f:
        f.write(conteudo)
    print(f'✅ Atualizado via Regex: {os.path.basename(destino)}')


###
# Função comum de processamento
###
def processar_csv():
    with open(CAMINHO_CSV, newline='', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f, delimiter=';')
        for row in reader:
            nome = row['Arquivo'].strip()
            canal = row['CANAL_TABELA'].strip()
            formato = row['FORMATO_TABELA'].strip()

            entrada = os.path.join(PASTA_XML_ORIGEM, nome)
            saida_etree = os.path.join(PASTA_XML_SAIDA_ELEMENTTREE, nome)
            saida_regex = os.path.join(PASTA_XML_SAIDA_REGEX, nome)

            if os.path.exists(entrada):
                corrigir_elementtree(entrada, canal, formato, saida_etree)
                corrigir_regex(entrada, canal, formato, saida_regex)
            else:
                print(f'❌ Arquivo não encontrado: {nome}')


if __name__ == '__main__':
    processar_csv()
