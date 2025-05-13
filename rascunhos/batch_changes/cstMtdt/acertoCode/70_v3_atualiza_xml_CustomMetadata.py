import csv
import os
import xml.etree.ElementTree as ET

# Namespace da Salesforce
SF_NS = 'http://soap.sforce.com/2006/04/metadata'
ET.register_namespace('', SF_NS)

# Função para atualizar campo no XML
def atualizar_valor(xml_path, novo_canal, novo_formato, destino='./saida_corrigida'):
    tree = ET.parse(xml_path)
    root = tree.getroot()

    # Atualiza o conteúdo dos campos Canal__c e Formato__c
    for values in root.findall(f'{{{SF_NS}}}values'):
        field = values.find(f'{{{SF_NS}}}field')
        value = values.find(f'{{{SF_NS}}}value')
        if field is not None and value is not None:
            if field.text == 'Canal__c':
                value.text = f'<string>{novo_canal}</string>'
            elif field.text == 'Formato__c':
                value.text = f'<string>{novo_formato}</string>'

    os.makedirs(destino, exist_ok=True)
    destino_arquivo = os.path.join(destino, os.path.basename(xml_path))
    tree.write(destino_arquivo, encoding='utf-8', xml_declaration=True)
    print(f'✅ Corrigido: {destino_arquivo}')


# Função principal: lê o CSV de correção
def processar_csv_alteracoes(caminho_csv, pasta_origem_xml='./saida_xml'):
    with open(caminho_csv, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter=';')
        for linha in reader:
            nome_arquivo = linha['Arquivo']
            canal_novo = linha['CANAL_TABELA']
            formato_novo = linha['FORMATO_TABELA']

            caminho_xml = os.path.join(pasta_origem_xml, nome_arquivo)
            if not os.path.exists(caminho_xml):
                print(f'⚠️ Arquivo XML não encontrado: {caminho_xml}')
                continue

            atualizar_valor(caminho_xml, canal_novo, formato_novo)


# 🧪 Execução principal
processar_csv_alteracoes('./3_saida_csv/1_listaCustomAlteracao.csv', pasta_origem_xml='./saida_xml')
