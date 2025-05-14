###
# SCRIPT - Cria arquivos XML de Custom Metadata a partir de um modelo e um CSV
# Formato de entrada:
# - CSV delimitado por ";" com os campos:
#     label;CampoRelacionamentoObjetoFilho;CampoRelacionamentoObjetoPai;CamposTela;Canal;Formato;Objeto;TelaUtilizada
# - Modelo XML com placeholders como {{LABEL_FULL}}, {{DOMINIO_CANAL}}, etc.
###

import os
import csv

# Caminhos ajustáveis
CAMINHO_CSV = './3_saida_csv/2_listaVinculosPrecisamCustom.csv'
CAMINHO_MODELO = './1_metadados/BaseCustomMetadata.xml'
PASTA_SAIDA = './4_xml_gerado_custom'

# Garantir pasta de saída
os.makedirs(PASTA_SAIDA, exist_ok=True)

# Carrega modelo base
with open(CAMINHO_MODELO, 'r', encoding='utf-8') as f:
    modelo = f.read()

# Substituição linha a linha do CSV
with open(CAMINHO_CSV, newline='', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f, delimiter=';')
    for row in reader:
        nome_arquivo = row['label'].strip()
        if not nome_arquivo.endswith('.xml'):
            nome_arquivo += '.xml'

        substituido = modelo
        substituido = substituido.replace('{{LABEL_FULL}}', row['label'].strip())
        substituido = substituido.replace('{{CampoRelacionamentoObjetoFilho}}', row['CampoRelacionamentoObjetoFilho'].strip())
        substituido = substituido.replace('{{CampoRelacionamentoObjetoPai}}', row['CampoRelacionamentoObjetoPai'].strip())
        substituido = substituido.replace('{{CamposTela}}', row['CamposTela'].strip())
        substituido = substituido.replace('{{DOMINIO_CANAL}}', row['Canal'].strip())
        substituido = substituido.replace('{{DOMINIO_FORMATO}}', row['Formato'].strip())
        substituido = substituido.replace('{{Objeto}}', row['Objeto'].strip())
        substituido = substituido.replace('{{TelaUtilizada}}', row['TelaUtilizada'].strip())

        caminho_saida = os.path.join(PASTA_SAIDA, nome_arquivo)
        with open(caminho_saida, 'w', encoding='utf-8', newline='\n') as fout:
            fout.write(substituido)
        print(f'✅ Gerado: {nome_arquivo}')
