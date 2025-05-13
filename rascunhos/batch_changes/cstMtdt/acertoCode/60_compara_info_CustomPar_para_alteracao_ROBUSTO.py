
import csv
import os

# Variáveis de entrada e saída
arquivo_xml_custom = './1_metadados/_DadoCustomMetadata_ref.csv'
arquivo_tabela = './1_metadados/_VincParCustom-CanalFormato.csv'
arquivo_saida_para_alteracao = './3_saida_xml/1_listaCustomAlteracao.csv'
arquivo_saida_para_criacao = './3_saida_xml/2_listaVinculosPrecisamCustom.csv'

# Garante que as pastas de saída existem
for caminho in [arquivo_saida_para_alteracao, arquivo_saida_para_criacao]:
    pasta = os.path.dirname(caminho)
    if not os.path.exists(pasta):
        os.makedirs(pasta)

# Função para normalizar texto e facilitar comparação
def normalizar(texto):
    return ''.join(filter(str.isalnum, texto.lower()))

# Carrega dados da tabela de referência
tabela = []
try:
    with open(arquivo_tabela, newline='', encoding='utf-8', errors='replace') as f:
        reader = csv.DictReader(f, delimiter=';')
        for row in reader:
            canal = row.get('CanalTab', '').strip()
            formato = row.get('FormatoTab', '').strip()
            tem_dado_espec = row.get('FormTemDadoEspec', '').strip().lower() == 'true'
            if canal and formato:
                tabela.append({
                    'canal': canal,
                    'formato': formato,
                    'tem_dado_espec': tem_dado_espec
                })
except Exception as e:
    print(f"Erro ao ler arquivo de tabela: {arquivo_tabela}")
    raise e

# Inicializa a saída para criação
try:
    with open(arquivo_saida_para_criacao, 'w', newline='', encoding='utf-8') as f_saida_criacao:
        writer_criacao = csv.writer(f_saida_criacao, delimiter=';')
        writer_criacao.writerow([
            'label',
            'CampoRelacionamentoObjetoFilho',
            'CampoRelacionamentoObjetoPai',
            'CamposTela',
            'Canal',
            'Formato',
            'Objeto',
            'TelaUtilizada'
        ])
except Exception as e:
    print(f"Erro ao criar arquivo de saída para criação: {arquivo_saida_para_criacao}")
    raise e

# Inicializa a saída para alterações
try:
    with open(arquivo_saida_para_alteracao, 'w', newline='', encoding='utf-8') as f_saida:
        writer = csv.writer(f_saida, delimiter=';')
        writer.writerow(['Arquivo', 'Label', 'CANAL_XML', 'FORMATO_XML', 'FORMATO_TABELA', 'CANAL_TABELA'])
except Exception as e:
    print(f"Erro ao criar arquivo de saída para alterações: {arquivo_saida_para_alteracao}")
    raise e

usados = set()

# Processa o XML de referência com proteção contra erros de leitura
try:
    with open(arquivo_xml_custom, newline='', encoding='utf-8', errors='replace') as f_origem:
        reader = csv.DictReader(f_origem, delimiter=';')
        for row in reader:
            nome_arquivo = row.get('NomeArquivoXml', '').strip()
            label = row.get('Label', '').strip()
            canal_xml = row.get('CanalXml', '').strip()
            formato_xml = row.get('FormatoXml', '').strip()

            if not nome_arquivo.startswith('WM2') or not canal_xml or not formato_xml:
                continue

            for item in tabela:
                canal_tab = item['canal']
                formato_tab = item['formato']

                if canal_xml != canal_tab:
                    continue
                if (canal_tab, formato_tab) in usados:
                    continue
                if formato_tab == formato_xml:
                    continue
                if normalizar(formato_tab) in normalizar(formato_xml) or normalizar(formato_xml) in normalizar(formato_tab):
                    print(f"\n▶ Possível correspondência encontrada:")
                    print(f"Arquivo:        {nome_arquivo}")
                    print(f"Label:          {label}")
                    print(f"CANAL_XML:      {canal_xml}")
                    print(f"FORMATO_XML:    {formato_xml}")
                    print(f"CANAL_TABELA:   {canal_tab}")
                    print(f"FORMATO_TABELA: {formato_tab}")
                    while True:
                        resposta = input("Deseja gravar esse registro como novo? (s/n): ").strip().lower()
                        if resposta == 's':
                            with open(arquivo_saida_para_alteracao, 'a', newline='', encoding='utf-8') as f_saida:
                                writer = csv.writer(f_saida, delimiter=';')
                                writer.writerow([nome_arquivo, label, canal_xml, formato_xml, formato_tab, canal_tab])
                            usados.add((canal_tab, formato_tab))
                            print("✅ Registro salvo.")
                            break
                        elif resposta == 'n':
                            print("⏩ Ignorado.")
                            break
                        else:
                            print("❌ Resposta inválida. Digite 's' ou 'n'.")
except Exception as e:
    print(f"Erro ao ler e processar o arquivo XML custom: {arquivo_xml_custom}")
    raise e

# Cria novos registros se necessário
contador_criacao = 1
try:
    with open(arquivo_saida_para_criacao, 'a', newline='', encoding='utf-8') as f_saida_criacao:
        writer_criacao = csv.writer(f_saida_criacao, delimiter=';')
        for item in tabela:
            if item['tem_dado_espec'] and (item['canal'], item['formato']) not in usados:
                sigla_formatada = normalizar(item['formato']).replace(' ', '_')
                nome_custom = f"CamposCanalFormato.{sigla_formatada}{contador_criacao:03d}-md-meta.xml"
                writer_criacao.writerow([
                    nome_custom,
                    '',
                    '',
                    '',
                    item['canal'],
                    item['formato'],
                    '',
                    ''
                ])
                contador_criacao += 1
except Exception as e:
    print(f"Erro ao gravar os novos registros de criação: {arquivo_saida_para_criacao}")
    raise e
