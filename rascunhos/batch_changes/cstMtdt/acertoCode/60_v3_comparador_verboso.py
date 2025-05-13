import csv
import os

# Caminhos
arquivo_xml_custom = './1_metadados/_DadoCustomMetadata_ref.csv'
arquivo_tabela = './1_metadados/_VincParCustom-CanalFormato.csv'
arquivo_saida_para_alteracao = './3_saida_xml/1_listaCustomAlteracao.csv'
arquivo_saida_para_criacao = './3_saida_xml/2_listaVinculosPrecisamCustom.csv'

# Garante que os diretórios de saída existem
os.makedirs(os.path.dirname(arquivo_saida_para_alteracao), exist_ok=True)
os.makedirs(os.path.dirname(arquivo_saida_para_criacao), exist_ok=True)

def normalizar(texto):
    return ''.join(filter(str.isalnum, str(texto).strip().lower()))

def validar_csv_por_linha(caminho, esperado):
    print(f"\n📋 Validando arquivo: {caminho}")
    with open(caminho, 'r', encoding='utf-8-sig', newline='') as f:
        linhas = f.readlines()
        delimitador = ','
        header = linhas[0].strip().split(delimitador)
        if len(header) != esperado:
            print(f"❌ Cabeçalho com {len(header)} campos, esperados {esperado}: {header}")
            return False
        for i, linha in enumerate(linhas[1:], start=2):
            campos = linha.strip().split(delimitador)
            if len(campos) != esperado:
                print(f"❌ Linha {i} com {len(campos)} campos: {linha.strip()}")
                return False
    print("✅ Arquivo validado com sucesso!")
    return True

# Valida os dois arquivos antes de continuar
if not validar_csv_por_linha(arquivo_xml_custom, 4):
    exit(1)
if not validar_csv_por_linha(arquivo_tabela, 3):
    exit(1)

def carregar_csv(path, delimitador=','):
    with open(path, 'r', encoding='utf-8-sig', newline='') as f:
        reader = csv.DictReader(f, delimiter=delimitador)
        linhas = list(reader)
        print(f"\n📂 {path} carregado com {len(linhas)} linhas. Cabeçalhos: {reader.fieldnames}")
        return linhas

print("\n🚀 Iniciando comparação...")
tabela = carregar_csv(arquivo_tabela, delimitador=',')
origem = carregar_csv(arquivo_xml_custom, delimitador=',')

# Normaliza a tabela de referência
referencia = []
for linha in tabela:
    canal = linha.get('CanalTab', '').strip()
    formato = linha.get('FormatoTab', '').strip()
    tem_dado_flag = linha.get('FormTemDadoEspec', 'false')
    tem_dado_espec = str(tem_dado_flag).strip().lower() == 'true'

    if canal and formato:
        referencia.append({
            'canal': canal,
            'formato': formato,
            'tem_dado_espec': tem_dado_espec
        })

print(f"🔍 {len(referencia)} pares canal+formato carregados da tabela de referência")

# Arquivos de saída
with open(arquivo_saida_para_alteracao, 'w', newline='', encoding='utf-8') as f_out:
    writer = csv.writer(f_out, delimiter=';')
    writer.writerow(['Arquivo', 'Label', 'CANAL_XML', 'FORMATO_XML', 'FORMATO_TABELA', 'CANAL_TABELA'])

with open(arquivo_saida_para_criacao, 'w', newline='', encoding='utf-8') as f_cria:
    writer = csv.writer(f_cria, delimiter=';')
    writer.writerow(['label', 'CampoRelacionamentoObjetoFilho', 'CampoRelacionamentoObjetoPai',
                     'CamposTela', 'Canal', 'Formato', 'Objeto', 'TelaUtilizada'])

# Processamento
usados = set()
for row in origem:
    nome = row.get('NomeArquivoXml', '').strip()
    label = row.get('Label', '').strip()
    canal_xml = row.get('CanalXml', '').strip()
    formato_xml = row.get('FormatoXml', '').strip()

    if not nome or not canal_xml or not formato_xml:
        print(f"⚠️ Ignorado por dados faltantes: {nome} | {canal_xml} | {formato_xml}")
        continue

    encontrou = False
    for ref in referencia:
        canal_tab = ref['canal']
        formato_tab = ref['formato']

        if canal_xml != canal_tab:
            continue

        if (canal_tab, formato_tab) in usados:
            continue

        if formato_tab == formato_xml:
            continue

        if normalizar(formato_tab) in normalizar(formato_xml) or normalizar(formato_xml) in normalizar(formato_tab):
            encontrou = True
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
            break

    if not encontrou:
        print(f"❌ Nenhuma correspondência para: {nome} | {canal_xml} | {formato_xml}")

# Cria novos registros
contador = 1
with open(arquivo_saida_para_criacao, 'a', newline='', encoding='utf-8') as f_cria:
    writer = csv.writer(f_cria, delimiter=';')
    for item in referencia:
        if item['tem_dado_espec'] and (item['canal'], item['formato']) not in usados:
            nome_custom = f"CamposCanalFormato.{normalizar(item['formato'])}{contador:03d}-md-meta.xml"
            writer.writerow([nome_custom, '', '', '', item['canal'], item['formato'], '', ''])
            contador += 1

print("\n🏁 PROCESSAMENTO FINALIZADO.")
