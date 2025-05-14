###
# SCRIPT 2 - Atualiza XML via regex (preserva estrutura original do XML)
# Salve como: atualizar_regex.py
###

import os
import csv
import re

# Diretórios ajustáveis:
CAMINHO_CSV = './3_saida_csv/1_listaCustomAlteracao.csv'
PASTA_XML_ORIGEM = './2_entrada_xml'
PASTA_XML_SAIDA = './4_xml_corrigido_regex'

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
                corrigir_regex(entrada, canal, formato, saida)
            else:
                print(f'❌ Arquivo não encontrado: {nome}')

if __name__ == '__main__':
    processar_csv()
