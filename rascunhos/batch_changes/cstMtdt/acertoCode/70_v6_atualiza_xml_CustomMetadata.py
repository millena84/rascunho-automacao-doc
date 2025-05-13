import os
import csv
import xml.etree.ElementTree as ET

# Constantes
CAMINHO_CSV = './3_saida_csv/1_listaCustomAlteracao.csv'
PASTA_XML_ORIGEM = './2_entrada_xml'
PASTA_XML_SAIDA = './4_xml_corrigido'

# Corrige prefixo ns0
NAMESPACE = "http://soap.sforce.com/2006/04/metadata"
ET.register_namespace('', NAMESPACE)

def corrigir_xml(nome_arquivo, canal_novo, formato_novo):
    caminho_entrada = os.path.join(PASTA_XML_ORIGEM, nome_arquivo)

    if not os.path.exists(caminho_entrada):
        print(f'❌ XML NÃO ENCONTRADO: {nome_arquivo}')
        return False

    try:
        tree = ET.parse(caminho_entrada)
        root = tree.getroot()

        alterado = False

        for values in root.findall(f'{{{NAMESPACE}}}values'):
            field = values.find(f'{{{NAMESPACE}}}field')
            value = values.find(f'{{{NAMESPACE}}}value')
            if field is not None and value is not None:
                if field.text == 'Canal__c':
                    value.text = f'<string>{canal_novo}</string>'
                    alterado = True
                elif field.text == 'Formato__c':
                    value.text = f'<string>{formato_novo}</string>'
                    alterado = True

        if alterado:
            os.makedirs(PASTA_XML_SAIDA, exist_ok=True)
            destino = os.path.join(PASTA_XML_SAIDA, nome_arquivo)
            tree.write(destino, encoding='utf-8', xml_declaration=True)
            print(f'✅ Corrigido: {nome_arquivo}')
        else:
            print(f'⚠️ Campos não encontrados em: {nome_arquivo}')

        return True

    except Exception as e:
        print(f'❌ ERRO ao processar {nome_arquivo}: {e}')
        return False

def processar_csv():
    try:
        with open(CAMINHO_CSV, newline='', encoding='utf-8-sig') as f:
            reader = csv.DictReader(f, delimiter=';')
            print(f'📌 Cabeçalhos detectados: {reader.fieldnames}')
            
            total = 0
            ignorados = 0

            for linha in reader:
                nome = linha.get('Arquivo', '').strip()
                canal_tab = linha.get('CANAL_TABELA', '').strip()
                formato_tab = linha.get('FORMATO_TABELA', '').strip()

                if not nome or not canal_tab or not formato_tab:
                    ignorados += 1
                    print(f'⚠️ Ignorado (dados ausentes): Arquivo="{nome}", Canal="{canal_tab}", Formato="{formato_tab}"')
                    continue

                sucesso = corrigir_xml(nome, canal_tab, formato_tab)
                if sucesso:
                    total += 1

            print(f'\n🏁 FIM: {total} corrigidos, {ignorados} ignorados.')

    except Exception as e:
        print(f'❌ ERRO AO LER CSV: {e}')

# Execução principal
if __name__ == '__main__':
    processar_csv()
