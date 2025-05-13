import csv
import os
from datetime import datetime

# Caminhos
arquivo_xml_custom = './1_metadados/_DadoCustomMetadata_ref.csv'
arquivo_tabela = './1_metadados/_VincParCustom-CanalFormato.csv'
arquivo_saida_para_alteracao = './3_saida_xml/1_listaCustomAlteracao.csv'
arquivo_saida_para_criacao = './3_saida_xml/2_listaVinculosPrecisamCustom.csv'
arquivo_log = './3_saida_xml/estatisticas_comparacao.txt'

# Garante que os diretórios de saída existem
os.makedirs(os.path.dirname(arquivo_saida_para_alteracao), exist_ok=True)
os.makedirs(os.path.dirname(arquivo_saida_para_criacao), exist_ok=True)

estatisticas = {
    'total_xml': 0,
    'total_tabela': 0,
    'comparacoes_feitas': 0,
    'gravados_alteracao': 0,
    'gravados_criacao': 0,
    'ignorados': 0,
    'sem_correspondencia': 0
}

def normalizar(texto):
    return ''.join(filter(str.isalnum, str(texto).strip().lower()))

def diagnosticar_csv_estrutural(caminho, esperado, nome):
    print(f"\n📋 Diagnosticando estrutura do CSV: {nome}")
    try:
        with open(caminho, 'r', encoding='utf-8-sig', newline='') as f:
            linhas = f.readlines()
            delimitador = ';' if linhas[0].count(';') >= linhas[0].count(',') else ','
            cabecalho = linhas[0].strip().split(delimitador)
            if len(cabecalho) != esperado:
                print(f"❌ Cabeçalho com {len(cabecalho)} colunas (esperado: {esperado}): {cabecalho}")
                return False
            for i, linha in enumerate(linhas[1:], start=2):
                if linha.strip() == '':
                    continue
                if linha.count(delimitador) != (esperado - 1):
                    print(f"❌ Linha {i} com {linha.count(delimitador)+1} colunas: {linha.strip()}")
                    return False
        print("✅ Estrutura do CSV validada com sucesso!")
        return True
    except Exception as e:
        print(f"❌ Erro ao diagnosticar {nome}: {e}")
        return False

if not diagnosticar_csv_estrutural(arquivo_xml_custom, 4, '_DadoCustomMetadata_ref.csv'):
    exit(1)
if not diagnosticar_csv_estrutural(arquivo_tabela, 3, '_VincParCustom-CanalFormato.csv'):
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

estatisticas['total_tabela'] = len(tabela)
estatisticas['total_xml'] = len(origem)

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
        estatisticas['ignorados'] += 1
        continue

    estatisticas['comparacoes_feitas'] += 1
    encontrou = False

    similares = [ref for ref in referencia if ref['canal'] == canal_xml]
    for ref in similares:
        canal_tab = ref['canal']
        formato_tab = ref['formato']

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
                estatisticas['gravados_alteracao'] += 1
                print("✅ Gravado.")
                break
            else:
                print("⏩ Ignorado. Buscando outros semelhantes...")

    if not encontrou:
        print(f"❌ Nenhuma correspondência para: {nome} | {canal_xml} | {formato_xml}")
        estatisticas['sem_correspondencia'] += 1

# Cria novos registros
contador = 1
with open(arquivo_saida_para_criacao, 'a', newline='', encoding='utf-8') as f_cria:
    writer = csv.writer(f_cria, delimiter=';')
    for item in referencia:
        if item['tem_dado_espec'] and (item['canal'], item['formato']) not in usados:
            nome_custom = f"CamposCanalFormato.{normalizar(item['formato'])}{contador:03d}-md-meta.xml"
            writer.writerow([nome_custom, '', '', '', item['canal'], item['formato'], '', ''])
            contador += 1
            estatisticas['gravados_criacao'] += 1

# Gerar log final
with open(arquivo_log, 'w', encoding='utf-8') as flog:
    flog.write(f"Estatísticas de Execução - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    for chave, valor in estatisticas.items():
        flog.write(f"{chave}: {valor}\n")

print("\n🏁 PROCESSAMENTO FINALIZADO. Estatísticas salvas em:", arquivo_log)
