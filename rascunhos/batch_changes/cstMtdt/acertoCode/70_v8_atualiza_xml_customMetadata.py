import os
import csv
import re

# Configurações de caminho
CAMINHO_CSV = './3_saida_csv/1_listaCustomAlteracao.csv'
PASTA_XML_ORIGEM = './2_entrada_xml'
PASTA_XML_SAIDA = './4_xml_corrigido'

# Substitui apenas os valores de Canal__c e Formato__c no conteúdo do XML
def atualizar_valores_xml_com_regex(caminho_entrada, canal_novo, formato_novo, destino):
    with open(caminho_entrada, 'r', encoding='utf-8') as f:
        conteudo = f.read()

    # Substitui valor de Canal__c
    canal_regex = re.compile(r'(<field>\s*Canal__c\s*</field>\s*<value>)(.*?)(</value>)', re.DOTALL)
    conteudo, subs1 = canal_regex.subn(rf'\1{canal_novo}\3', conteudo)

    # Substitui valor de Formato__c
    formato_regex = re.compile(r'(<field>\s*Formato__c\s*</field>\s*<value>)(.*?)(</value>)', re.DOTALL)
    conteudo, subs2 = formato_regex.subn(rf'\1{formato_novo}\3', conteudo)

    if subs1 == 0 or subs2 == 0:
        print(f'⚠️ Não encontrou os campos no arquivo: {os.path.basename(caminho_entrada)}')
    else:
        os.makedirs(os.path.dirname(destino), exist_ok=True)
        with open(destino, 'w', encoding='utf-8', newline='\n') as f:
            f.write(conteudo)
        print(f'✅ Atualizado sem quebrar estrutura: {os.path.basename(destino)}')

# Processa o CSV com base nas colunas Arquivo;CANAL_TABELA;FORMATO_TABELA
def processar_csv():
    try:
        with open(CAMINHO_CSV, newline='', encoding='utf-8-sig') as f:
            reader = csv.DictReader(f, delimiter=';')
            print(f'📌 Cabeçalhos lidos: {reader.fieldnames}')

            total = 0
            ignorados = 0

            for linha in reader:
                nome = linha.get('Arquivo', '').strip()
                canal_tab = linha.get('CANAL_TABELA', '').strip()
                formato_tab = linha.get('FORMATO_TABELA', '').strip()

                if not nome or not canal_tab or not formato_tab:
                    ignorados += 1
                    print(f'⚠️ Ignorado (dados ausentes): {linha}')
                    continue

                caminho_origem = os.path.join(PASTA_XML_ORIGEM, nome)
                caminho_destino = os.path.join(PASTA_XML_SAIDA, nome)

                if not os.path.exists(caminho_origem):
                    print(f'❌ Arquivo XML não encontrado: {nome}')
                    continue

                atualizar_valores_xml_com_regex(caminho_origem, canal_tab, formato_tab, caminho_destino)
                total += 1

            print(f'\n🏁 FIM: {total} atualizados, {ignorados} ignorados.')

    except Exception as e:
        print(f'❌ ERRO ao processar CSV: {e}')

# Executa o script
if __name__ == '__main__':
    processar_csv()
