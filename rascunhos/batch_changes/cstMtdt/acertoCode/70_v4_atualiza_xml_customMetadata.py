import csv
import os
import xml.etree.ElementTree as ET

# Namespace padrão da Salesforce
SF_NS = 'http://soap.sforce.com/2006/04/metadata'
ET.register_namespace('', SF_NS)

# 🧩 Função para atualizar Canal__c e Formato__c
def atualizar_valores_xml(xml_path, canal_novo, formato_novo, pasta_destino='./4_xml_corrigido'):
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()

        for values in root.findall(f'{{{SF_NS}}}values'):
            field = values.find(f'{{{SF_NS}}}field')
            value = values.find(f'{{{SF_NS}}}value')
            if field is not None and value is not None:
                if field.text == 'Canal__c':
                    value.text = f'<string>{canal_novo}</string>'
                elif field.text == 'Formato__c':
                    value.text = f'<string>{formato_novo}</string>'

        os.makedirs(pasta_destino, exist_ok=True)
        nome_arquivo = os.path.basename(xml_path)
        destino_completo = os.path.join(pasta_destino, nome_arquivo)
        tree.write(destino_completo, encoding='utf-8', xml_declaration=True)
        print(f'✅ Corrigido: {destino_completo}')

    except Exception as e:
        print(f'❌ Erro ao processar {xml_path}: {e}')


# 🗃️ Função principal: lê CSV e aplica alterações nos XMLs da pasta 2_entrada_xml
def processar_alteracoes_csv(caminho_csv, pasta_xml_entrada='./2_entrada_xml', pasta_xml_corrigido='./4_xml_corrigido'):
    with open(caminho_csv, newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter=';')
        for linha in reader:
            nome_arquivo = linha.get('Arquivo', '').strip()
            canal_novo = linha.get('CANAL_TABELA', '').strip()
            formato_novo = linha.get('FORMATO_TABELA', '').strip()

            if not nome_arquivo or not canal_novo or not formato_novo:
                print(f'⚠️ Linha ignorada por dados ausentes: {linha}')
                continue

            caminho_xml = os.path.join(pasta_xml_entrada, nome_arquivo)
            if not os.path.exists(caminho_xml):
                print(f'❌ Arquivo XML não encontrado: {caminho_xml}')
                continue

            atualizar_valores_xml(caminho_xml, canal_novo, formato_novo, pasta_destino=pasta_xml_corrigido)


# ▶️ Execução
if __name__ == '__main__':
    caminho_csv = './3_saida_csv/1_listaCustomAlteracao.csv'
    processar_alteracoes_csv(caminho_csv)
