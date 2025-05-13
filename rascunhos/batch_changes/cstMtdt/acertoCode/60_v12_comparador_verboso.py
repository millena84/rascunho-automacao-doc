import csv
import os
from datetime import datetime
from difflib import SequenceMatcher

# Caminhos
arquivo_xml_custom = './1_metadados/_DadoCustomMetadata_ref_corrigido.csv'
arquivo_tabela = './1_metadados/_VincParCustom-CanalFormato.csv'
saida_alteracao = './3_saida_xml/1_listaCustomAlteracao.csv'
saida_criacao = './3_saida_xml/2_listaVinculosPrecisamCustom.csv'
saida_log = './3_saida_xml/estatisticas_comparacao.txt'
saida_sem_param = './3_saida_xml/CustomSemParam.csv'
saida_sem_alteracao = './3_saida_xml/CustomSemAlteracao.csv'

os.makedirs(os.path.dirname(saida_alteracao), exist_ok=True)

estatisticas = {
    'total_xml': 0,
    'total_tabela': 0,
    'comparacoes_feitas': 0,
    'gravados_alteracao': 0,
    'gravados_criacao': 0,
    'gravados_inalterado': 0,
    'ignorados': 0,
    'sem_correspondencia': 0,
    'sem_parametros': 0,
    'vinc_nao_utilizados': 0
}

def normalizar(texto):
    return ''.join(filter(str.isalnum, str(texto).strip().lower()))

def similaridade(a, b):
    return SequenceMatcher(None, normalizar(a), normalizar(b)).ratio()

def carregar_csv(path, delimitador=','):
    with open(path, 'r', encoding='utf-8-sig', newline='') as f:
        reader = csv.DictReader(f, delimiter=delimitador)
        linhas = list(reader)
        print(f"📂 {path} carregado com {len(linhas)} linhas. Cabeçalhos: {reader.fieldnames}")
        return linhas

print("🚀 Iniciando comparação...")

tabela = carregar_csv(arquivo_tabela)
origem = carregar_csv(arquivo_xml_custom)

estatisticas['total_tabela'] = len(tabela)
estatisticas['total_xml'] = len(origem)

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

usados = set()
nao_aprovados = []
vinc_usados = set()

with open(saida_alteracao, 'w', newline='', encoding='utf-8-sig') as f_out, \
     open(saida_criacao, 'w', newline='', encoding='utf-8-sig') as f_cria, \
     open(saida_sem_param, 'w', newline='', encoding='utf-8-sig') as f_sem, \
     open(saida_sem_alteracao, 'w', newline='', encoding='utf-8-sig') as f_inalterado:

    writer_alt = csv.writer(f_out, delimiter=';')
    writer_alt.writerow(['Arquivo', 'Label', 'CANAL_XML', 'FORMATO_XML', 'FORMATO_TABELA', 'CANAL_TABELA'])

    writer_cria = csv.writer(f_cria, delimiter=';')
    writer_cria.writerow(['label', 'CampoRelacionamentoObjetoFilho', 'CampoRelacionamentoObjetoPai',
                          'CamposTela', 'Canal', 'Formato', 'Objeto', 'TelaUtilizada'])

    writer_sem = csv.writer(f_sem, delimiter=';')
    writer_sem.writerow(['Origem', 'NomeArquivoXml', 'Label', 'CanalXml', 'FormatoXml'])

    writer_inalt = csv.writer(f_inalterado, delimiter=';')
    writer_inalt.writerow(['NomeArquivoXml', 'Label', 'CanalXml', 'FormatoXml'])

    for row in origem:
        nome = row.get('NomeArquivoXml', '').strip()
        label = row.get('Label', '').strip()
        canal_xml = row.get('CanalXml', '').strip()
        formato_xml = row.get('FormatoXml', '').strip()

        if not nome or not canal_xml or not formato_xml:
            estatisticas['ignorados'] += 1
            continue

        estatisticas['comparacoes_feitas'] += 1

        candidatos = [
            ref for ref in referencia
            if ref['canal'].strip() == canal_xml and (ref['canal'], ref['formato']) not in usados
        ]

        if not candidatos:
            writer_sem.writerow(['DadoCustom', nome, label, canal_xml, formato_xml])
            estatisticas['sem_parametros'] += 1
            continue

        similares = sorted(
            candidatos,
            key=lambda r: -similaridade(r['formato'], formato_xml)
        )

        match_confirmado = False
        for ref in similares:
            canal_tab = ref['canal']
            formato_tab = ref['formato']
            sim = similaridade(formato_tab, formato_xml)

            if sim == 1.0:
                writer_inalt.writerow([nome, label, canal_xml, formato_xml])
                estatisticas['gravados_inalterado'] += 1
                usados.add((canal_tab, formato_tab))
                match_confirmado = True
                break

            if sim >= 0.5:
                print(f"\n🔎 POSSÍVEL CORRESPONDÊNCIA (similaridade: {sim:.2f})")
                print(f"Arquivo:        {nome}")
                print(f"Label:          {label}")
                print(f"CANAL_XML:      {canal_xml}")
                print(f"FORMATO_XML:    {formato_xml}")
                print(f"CANAL_TABELA:   {canal_tab}")
                print(f"FORMATO_TABELA: {formato_tab}")
                resp = input("👉 Deseja gravar este como alteração? (s/n): ").strip().lower()
                if resp == 's':
                    writer_alt.writerow([nome, label, canal_xml, formato_xml, formato_tab, canal_tab])
                    usados.add((canal_tab, formato_tab))
                    estatisticas['gravados_alteracao'] += 1
                    match_confirmado = True
                    break
                else:
                    print("⏩ Ignorado. Buscando outros semelhantes...")

        if not match_confirmado:
            writer_sem.writerow(['DadoCustom', nome, label, canal_xml, formato_xml])
            estatisticas['sem_correspondencia'] += 1
            nao_aprovados.append((nome, canal_xml, formato_xml))

    contador = 1
    for item in referencia:
        if item['tem_dado_espec'] and (item['canal'], item['formato']) not in usados:
            nome_custom = f"CamposCanalFormato.{normalizar(item['formato'])}{contador:03d}-md-meta.xml"
            writer_cria.writerow([nome_custom, '', '', '', item['canal'], item['formato'], '', ''])
            contador += 1
            estatisticas['gravados_criacao'] += 1
            writer_sem.writerow(['VincParam', '', '', item['canal'], item['formato']])
            estatisticas['vinc_nao_utilizados'] += 1

# Log final
with open(saida_log, 'w', encoding='utf-8-sig') as flog:
    flog.write(f"Estatísticas de Execução - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    for chave, valor in estatisticas.items():
        flog.write(f"{chave}: {valor}\n")
    flog.write("\nRegistros sem correspondência confirmada:\n")
    for nome, canal, formato in nao_aprovados:
        flog.write(f"{nome},{canal},{formato}\n")

print("\n🏁 PROCESSAMENTO FINALIZADO. Estatísticas salvas em:", saida_log)
