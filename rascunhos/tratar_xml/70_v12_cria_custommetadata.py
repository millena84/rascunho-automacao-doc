

#SCRIPT 5 - Cria XML CustomMetadata via cópia de modelo + substituição com regex

# Salve como: criar_regex_modelo.py



import os import csv import shutil import re

Diretórios ajustáveis:

CSV_ENTRADA = './3_saida_csv/2_listaVinculosPrecisamCustom.csv' MODELO_XML = './5_modelo_base/CamposCanalFormato.MODELO.md-meta.xml'  # Arquivo modelo base PASTA_SAIDA = './5_xml_novos_regex'

def substituir_valores_em_modelo(modelo_path, destino_path, canal, formato): with open(modelo_path, 'r', encoding='utf-8') as f: conteudo = f.read()

canal_regex = re.compile(
    r'(<values>\s*<field>\s*Canal__c\s*</field>\s*<value[^>]*>)(.*?)(</value>\s*</values>)',
    re.DOTALL | re.IGNORECASE
)
formato_regex = re.compile(
    r'(<values>\s*<field>\s*Formato__c\s*</field>\s*<value[^>]*>)(.*?)(</value>\s*</values>)',
    re.DOTALL | re.IGNORECASE
)

conteudo, c1 = canal_regex.subn(rf'\1{canal}\3', conteudo)
conteudo, c2 = formato_regex.subn(rf'\1{formato}\3', conteudo)

if c1 == 0 or c2 == 0:
    print(f'❌ Falha ao substituir Canal ou Formato em: {os.path.basename(destino_path)}')
    return

os.makedirs(os.path.dirname(destino_path), exist_ok=True)
with open(destino_path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(conteudo)
print(f'✅ Criado via regex: {os.path.basename(destino_path)}')

def processar_csv(): with open(CSV_ENTRADA, newline='', encoding='utf-8-sig') as f: reader = csv.DictReader(f, delimiter=';') contador = 1

for row in reader:
        canal = row['Canal'].strip()
        formato = row['Formato'].strip()
        label = row['label'].strip()
        nome_arquivo = f'CamposCanalFormato.{formato.upper()}{contador:03}.md-meta.xml'
        destino = os.path.join(PASTA_SAIDA, nome_arquivo)

        substituir_valores_em_modelo(MODELO_XML, destino, canal, formato)
        contador += 1

if name == 'main': processar_csv()

