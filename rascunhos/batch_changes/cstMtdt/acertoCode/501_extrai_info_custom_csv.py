import os
import csv
import xml.etree.ElementTree as ET

PASTA_ENTRADA = './2_entrada_xml_test'
ARQUIVO_SAIDA = './1_metadados/_DadoCustomMetadata_ref.csv'

# Garante que o diretório de saída existe
os.makedirs(os.path.dirname(ARQUIVO_SAIDA), exist_ok=True)

def extrair_info_xml(caminho_xml):
    try:
        tree = ET.parse(caminho_xml)
        root = tree.getroot()

        ns = {'sf': 'http://soap.sforce.com/2006/04/metadata'}

        label = root.find('sf:label', ns)
        label_text = label.text if label is not None else ''

        canal = ''
        formato = ''

        for values in root.findall('sf:values', ns):
            field = values.find('sf:field', ns)
            value = values.find('sf:value', ns)
            if field is not None and value is not None:
                if field.text == 'WW2_Canal__c':
                    canal = value.text or ''
                elif field.text == 'WW2_Formato__c':
                    formato = value.text or ''

        return [os.path.basename(caminho_xml), label_text, canal, formato]
    except Exception as e:
        print(f"⚠️ Erro ao processar {caminho_xml}: {e}")
        return None

def processar_pasta(pasta, saida_csv):
    arquivos = [f for f in os.listdir(pasta) if f.endswith('.xml')]
    total = len(arquivos)

    with open(saida_csv, 'w', newline='', encoding='utf-8-sig') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['NomeArquivoXml', 'Label', 'CanalXml', 'FormatoXml'])

        for i, nome_arquivo in enumerate(arquivos, start=1):
            caminho = os.path.join(pasta, nome_arquivo)
            resultado = extrair_info_xml(caminho)
            if resultado:
                writer.writerow(resultado)
            print(f'[{i}/{total}] Processado: {nome_arquivo}')

    print(f"\n✅ CSV salvo em: {saida_csv}")

# Execução principal
if __name__ == '__main__':
    print("🚀 Iniciando extração dos arquivos XML...")
    processar_pasta(PASTA_ENTRADA, ARQUIVO_SAIDA)
