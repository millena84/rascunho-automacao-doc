import csv
import difflib
import os

CSV_XML = './1_metadados/listaCustomMetadataParaComparacao.csv'
CSV_TABELA = './1_metadados/listaParametroParaComparacao.csv'
CSV_SAIDA = './3_saida_xml/listaCustomAlteracao.csv'

os.makedirs('./3_saida_xml', exist_ok=True)

print("🔍 Iniciando comparação...")

# Carrega todos os registros do arquivo da tabela de referência
with open(CSV_TABELA, newline='', encoding='utf-8') as tabela_file:
    tabela_reader = csv.reader(tabela_file)
    next(tabela_reader)  # pula cabeçalho
    lista_tabela = list(tabela_reader)

# Abre o CSV de saída para escrita
with open(CSV_SAIDA, 'w', newline='', encoding='utf-8') as saida_file:
    saida_writer = csv.writer(saida_file)
    saida_writer.writerow(['Arquivo', 'CANAL_TABELA', 'FORMATO_TABELA'])

    with open(CSV_XML, newline='', encoding='utf-8') as xml_file:
        xml_reader = csv.reader(xml_file)
        next(xml_reader)  # pula cabeçalho

        for linha_xml in xml_reader:
            if len(linha_xml) < 4:
                continue

            arquivo, label, canal_xml, formato_xml = linha_xml
            canal_xml = canal_xml.strip()
            formato_xml = formato_xml.strip()

            # Se existir correspondência exata, apenas ignora e segue
            match_exato = any(
                canal_xml.lower() == c_tab.strip().lower() and formato_xml.lower() == f_tab.strip().lower()
                for c_tab, f_tab in lista_tabela
            )
            if match_exato:
                continue

            for canal_tab, formato_tab in lista_tabela:
                canal_tab = canal_tab.strip()
                formato_tab = formato_tab.strip()
                canal_igual = canal_xml.lower() == canal_tab.lower()
                formato_parecido = difflib.SequenceMatcher(None, formato_xml.lower(), formato_tab.lower()).ratio()

                if canal_igual and formato_parecido > 0.7:
                    print("\n🔎 Possível correspondência encontrada:")
                    print(f"Arquivo:        {arquivo}")
                    print(f"Label:          {label}")
                    print(f"CANAL_XML:      {canal_xml}")
                    print(f"CANAL_TABELA**: {canal_tab}")
                    print(f"FORMATO_XML:    {formato_xml}")
                    print(f"FORMATO_TABELA**: {formato_tab}")

                    resposta = input("❓ Deseja gravar esse registro como novo? (s/n): ")
                    if resposta.lower() == 's':
                        # ALTERAR AQUI PARA INCLUIR INFORMACOES DE REFERENCIA
                        saida_writer.writerow([arquivo, canal_tab, formato_tab])
                        print("✅ Registro gravado com sucesso!")
                        break  # se confirmou, não precisa ver os outros
                    else:
                        print("⏭ Buscando próxima correspondência possível...")

print("\n🏁 Comparação finalizada. Resultado salvo em:", CSV_SAIDA)
