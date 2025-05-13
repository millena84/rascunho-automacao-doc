import csv
import os

# Caminhos dos arquivos
arquivo_xml_custom = './1_metadados/_DadoCustomMetadata_ref.csv'
arquivo_tabela = './1_metadados/_VincParCustom-CanalFormato.csv'
arquivo_saida_para_alteracao = './3_saida_xml/1_listaCustomAlteracao.csv'
arquivo_saida_para_criacao = './3_saida_xml/2_listaVinculosPrecisamCustom.csv'

# Garantir pastas
os.makedirs(os.path.dirname(arquivo_saida_para_alteracao), exist_ok=True)
os.makedirs(os.path.dirname(arquivo_saida_para_criacao), exist_ok=True)

def normalizar(texto):
    return ''.join(filter(str.isalnum, texto.strip().lower()))

# Detecta delimitador e lê CSV com cabeçalho
def carregar_csv_com_delimitador(path):
    with open(path, 'r', encoding='utf-8-sig', newline='') as f:
        amostra = f.read(1024)
        delimitador = ';' if amostra.count(';') > amostra.count(',') else ','
        f.seek(0)
        leitor = csv.DictReader(f, delimiter=delimitador)
        return list(leitor)

# Carrega CSVs
try:
    tabela = carregar_csv_com_delimitador(arquivo_tabela)
    origem = carregar_csv_com_delimitador(arquivo_xml_custom)
except Exception as e:
    print(f"❌ Erro ao carregar arquivos: {e}")
    exit(1)

# Valida colunas
if not tabela or 'CanalTab' not in tabela[0] or 'FormatoTab' not in tabela[0]:
    print("❌ Erro: coluna 'CanalTab' ou 'FormatoTab' não encontrada no arquivo da tabela.")
    exit(1)
if not origem or 'CanalXml' not in origem[0] or 'FormatoXml' not in origem[0]:
    print("❌ Erro: coluna 'CanalXml' ou 'FormatoXml' não encontrada no arquivo custom.")
    exit(1)

# Normaliza tabela de referência
referencia = []
for linha in tabela:
    canal = linha.get('CanalTab', '').strip()
    formato = linha.get('FormatoTab', '').strip()
    tem_dado = linha.get('FormTemDadoEspec', 'false').strip().lower() == 'true'
    if canal and formato:
        referencia.append({'canal': canal, 'formato': formato, 'tem_dado_espec': tem_dado})

# Inicia arquivos de saída
with open(arquivo_saida_para_alteracao, 'w', newline='', encoding='utf-8') as f_out:
    writer = csv.writer(f_out, delimiter=';')
    writer.writerow(['Arquivo', 'Label', 'CANAL_XML', 'FORMATO_XML', 'FORMATO_TABELA', 'CANAL_TABELA'])

with open(arquivo_saida_para_criacao, 'w', newline='', encoding='utf-8') as f_cria:
    writer = csv.writer(f_cria, delimiter=';')
    writer.writerow(['label', 'CampoRelacionamentoObjetoFilho', 'CampoRelacionamentoObjetoPai',
                     'CamposTela', 'Canal', 'Formato', 'Objeto', 'TelaUtilizada'])

# Processa
usados = set()
for row in origem:
    nome = row.get('NomeArquivoXml', '').strip()
    label = row.get('Label', '').strip()
    canal_xml = row.get('CanalXml', '').strip()
    formato_xml = row.get('FormatoXml', '').strip()

    if not nome.startswith('WM2') or not canal_xml or not formato_xml:
        continue

    for ref in referencia:
        canal_tab = ref['canal']
        formato_tab = ref['formato']
        if canal_xml != canal_tab or (canal_tab, formato_tab) in usados:
            continue
        if formato_tab == formato_xml:
            continue
        if normalizar(formato_tab) in normalizar(formato_xml) or normalizar(formato_xml) in normalizar(formato_tab):
            print("\n🔎 POSSÍVEL CORRESPONDÊNCIA ENCONTRADA:")
            print(f"Arquivo:        {nome}")
            print(f"Label:          {label}")
            print(f"CANAL_XML:      {canal_xml}")
            print(f"FORMATO_XML:    {formato_xml}")
            print(f"CANAL_TABELA:   {canal_tab}")
            print(f"FORMATO_TABELA: {formato_tab}")
            resp = input("👉 Deseja gravar este como alteração? (s/n): ").strip().lower()
            if resp == 's':
                with open(arquivo_saida_para_alteracao, 'a', newline='', encoding='utf-8') as f_out:
                    writer = csv.writer(f_out, delimiter=';')
                    writer.writerow([nome, label, canal_xml, formato_xml, formato_tab, canal_tab])
                usados.add((canal_tab, formato_tab))
                print("✅ Gravado.")
            else:
                print("⏩ Ignorado.")

# Agora salva os que precisam ser criados
contador = 1
with open(arquivo_saida_para_criacao, 'a', newline='', encoding='utf-8') as f_cria:
    writer = csv.writer(f_cria, delimiter=';')
    for item in referencia:
        if item['tem_dado_espec'] and (item['canal'], item['formato']) not in usados:
            nome_custom = f"CamposCanalFormato.{normalizar(item['formato'])}{contador:03d}-md-meta.xml"
            writer.writerow([nome_custom, '', '', '', item['canal'], item['formato'], '', ''])
            contador += 1

print("\n🏁 PROCESSAMENTO FINALIZADO.")
