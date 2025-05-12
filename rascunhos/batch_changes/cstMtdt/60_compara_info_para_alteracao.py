import csv
import os
## OBS: POSSIVEL EVOLUCAO: NA HORA DE GERAR AS LABELS, CONSIDERAR O PRIMEIRO CARACTERE DA PALAVRA MAIUSCULO E OS DEMAIS MINUSCULOS
# Variáveis de entrada e saída
arquivo_xml_custom = './1_metadados/listaCustomMetadataParaComparacao.csv'
arquivo_tabela = './1_metadados/listaParametroParaComparacao.csv'
arquivo_saida_para_alteracao = './3_saida_xml/listaCustomAlteracao.csv'
arquivo_saida_para_criacao = './3_saida_xml/listaParametrosCriacaoCustomMetadata.csv'

# Função para normalizar texto e facilitar comparação
def normalizar(texto):
    return ''.join(filter(str.isalnum, texto.lower()))

# Carrega dados da tabela de referência
tabela = []
with open(arquivo_tabela, newline='', encoding='utf-8') as f:
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

# Inicializa a saída para criação
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

# Cria arquivo de saída com cabeçalho para alterações
with open(arquivo_saida_para_alteracao, 'w', newline='', encoding='utf-8') as f_saida:
    writer = csv.writer(f_saida, delimiter=';')
    writer.writerow(['Arquivo', 'Label', 'CANAL_XML', 'FORMATO_XML', 'FORMATO_TABELA', 'CANAL_TABELA'])

    usados = set()

    with open(arquivo_xml_custom, newline='', encoding='utf-8') as f_origem:
        reader = csv.DictReader(f_origem, delimiter=';')
        for row in reader:
            nome_arquivo = row['NomeArquivoXml'].strip()
            label = row['Label'].strip()
            canal_xml = row['CanalXml'].strip()
            formato_xml = row['FormatoXml'].strip()

            if not nome_arquivo.startswith("WW2") or not canal_xml or not formato_xml:
                continue

            for item in tabela:
                canal_tab = item['canal']
                formato_tab = item['formato']

                if canal_xml != canal_tab:
                    continue  # canais diferentes, ignora

                if (canal_tab, formato_tab) in usados:
                    continue  # já gravado anteriormente, não precisa repetir

                if formato_tab == formato_xml:
                    continue  # formatos iguais, não precisa perguntar

                if normalizar(formato_tab) in normalizar(formato_xml) or normalizar(formato_xml) in normalizar(formato_tab):
                    print("\n🔎 Possível correspondência encontrada:")
                    print(f"Arquivo:        {nome_arquivo}")
                    print(f"Label:          {label}")
                    print(f"CANAL_XML:      {canal_xml}")
                    print(f"FORMATO_XML:    {formato_xml}")
                    print(f"FORMATO_TABELA: {formato_tab}")
                    print(f"CANAL_TABELA:   {canal_tab}")

                    while True:
                        resposta = input("❓ Deseja gravar esse registro como novo? (s/n): ").strip().lower()
                        if resposta == 's':
                            writer.writerow([nome_arquivo, label, canal_xml, formato_xml, formato_tab, canal_tab])
                            usados.add((canal_tab, formato_tab))
                            print("✅ Registro salvo.")
                            break  # Não processa mais correspondências para este XML
                        elif resposta == 'n':
                            print("⏭ Ignorado.")
                            break
                        else:
                            print("❌ Resposta inválida. Digite 's' ou 'n'.")

                    if resposta == 's':
                        break  # Sai do loop da tabela e vai para o próximo XML

# Agora processa os itens da tabela que não foram usados e possuem "tem_dado_espec" = true
contador_criacao = 1
with open(arquivo_saida_para_criacao, 'a', newline='', encoding='utf-8') as f_saida_criacao:
    writer_criacao = csv.writer(f_saida_criacao, delimiter=';')
    for item in tabela:
        if item['tem_dado_espec'] and (item['canal'], item['formato']) not in usados:
            sigla_formatada = normalizar(item['formato'].replace(' ', '_'))
            nome_custom = f"CamposCanalFormato.{sigla_formatada}${contador_criacao:03d}.md-meta.xml"
            writer_criacao.writerow([
                nome_custom,
                '', '', '',
                item['canal'],
                item['formato'],
                '', ''
            ])
            contador_criacao += 1
