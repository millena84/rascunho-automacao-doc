Estrutura do processo completo de extração e carga de dados entre orgs Salesforce

Autor: Jubileu

🔍 1. Python: gera arquivos de query com base no JSON de configuração

Arquivo: 01_gerar_queries_extracao.py

import json import os

CAMINHO_CONFIG = './_configEqualiza.json' PASTA_SAIDA = './queries' os.makedirs(PASTA_SAIDA, exist_ok=True)

with open(CAMINHO_CONFIG, 'r', encoding='utf-8') as f: dados = json.load(f)

registros = dados['infoEqualizaTestes']['INFO_REF_PROD']['INFO_REGS_EXTRACAO'] tabelas_processadas = set()

for grupo in registros: todas_tabelas = [(grupo['TAB_PRINC'], grupo['ID_UI_SF'])] todas_tabelas += [(t['TAB'], t['ID_UI_SF']) for t in grupo.get('TABS_ADD', [])] todas_tabelas += [(t['TAB'], t['ID_UI_SF']) for t in grupo.get('TABS_PAR', [])]

for nome_tab, id_ui in todas_tabelas:
    tab_clean = nome_tab.strip('_')
    id_clean = id_ui.strip()
    nome_arquivo = f"{tab_clean}_{id_clean}.txt"
    caminho_arquivo = os.path.join(PASTA_SAIDA, nome_arquivo)
    if caminho_arquivo in tabelas_processadas:
        continue
    tabelas_processadas.add(caminho_arquivo)
    query = f"SELECT Id, Name FROM {tab_clean} WHERE {id_clean} != null"
    with open(caminho_arquivo, 'w', encoding='utf-8') as f:
        f.write(query)

📂 Saída: arquivos de texto com queries no formato NOME_TABELA_AUTONUMBER.txt

🔧 2. Shell: consulta os dados na produção com as queries geradas

Arquivo: 02_executar_extracao_dados.sh

Esse shell roda no terminal, lê as queries da pasta e gera arquivos CSV/json

#!/bin/bash mkdir -p dados_extracao for arquivo in ./queries/*.txt; do nome_base=$(basename "$arquivo" .txt) echo "Extraindo dados de: $nome_base" sf data query --query "$(cat $arquivo)" --output csv > "dados_extracao/${nome_base}.csv"

Alternativamente, para JSON:

sf data query --query "$(cat $arquivo)" --json > "dados_extracao/${nome_base}.json"

done

📃 3. Python: prepara os arquivos para importação (limpeza, add identificador)

Arquivo: 03_preparar_csv_importacao.py

import pandas as pd import os

PASTA_ENTRADA = './dados_extracao' PASTA_SAIDA = './dados_importacao' os.makedirs(PASTA_SAIDA, exist_ok=True)

for arq in os.listdir(PASTA_ENTRADA): if arq.endswith('.csv'): df = pd.read_csv(os.path.join(PASTA_ENTRADA, arq)) if 'CodigoImportacao__c' not in df.columns: df['CodigoImportacao__c'] = df['Id'].apply(lambda x: f"REF_{x[-6:]}") df.drop(columns=['Id'], inplace=True, errors='ignore') df.to_csv(os.path.join(PASTA_SAIDA, arq), index=False)

🔧 4. Shell: importa dados principais na dev (primeira onda)

Arquivo: 04_importar_dados_principais.sh

#!/bin/bash mkdir -p resultados_import for arq in ./dados_importacao/*.csv; do nome_base=$(basename "$arq" .csv) echo "Importando dados para: $nome_base" sf data import --sobjecttype "$nome_base" --files "$arq" --json > "resultados_import/${nome_base}_resultado.json" done

🔢 5. Python: mapeia os novos IDs gerados

Arquivo: 05_mapear_novos_ids.py

import json import os

PASTA_RESULTADOS = './resultados_import' PASTA_SAIDA = './ids_mapeados' os.makedirs(PASTA_SAIDA, exist_ok=True)

for arq in os.listdir(PASTA_RESULTADOS): if arq.endswith('_resultado.json'): with open(os.path.join(PASTA_RESULTADOS, arq)) as f: dados = json.load(f) mapeamento = {} for r in dados.get('result', []): ref = r.get('referenceId') or r.get('CodigoImportacao__c') novo_id = r.get('id') if ref and novo_id: mapeamento[ref] = novo_id nome_saida = arq.replace('_resultado.json', '_ids.json') with open(os.path.join(PASTA_SAIDA, nome_saida), 'w') as fout: json.dump(mapeamento, fout, indent=2)

🔬 6. Python: atualiza os CSVs de filhos com os novos IDs nos campos de lookup

Arquivo: 06_aplicar_ids_nos_lookups.py

import pandas as pd import json

PASTA_CSV = './dados_importacao_filhos' PASTA_IDS = './ids_mapeados' PASTA_SAIDA = './dados_importacao_lookup_corrigido' os.makedirs(PASTA_SAIDA, exist_ok=True)

for arq in os.listdir(PASTA_CSV): if arq.endswith('.csv'): df = pd.read_csv(os.path.join(PASTA_CSV, arq)) for id_arq in os.listdir(PASTA_IDS): with open(os.path.join(PASTA_IDS, id_arq)) as f: mapeamento = json.load(f) for col in df.columns: if col.endswith('__c'): df[col] = df[col].map(mapeamento).fillna(df[col]) df.to_csv(os.path.join(PASTA_SAIDA, arq), index=False)

📊 7. Shell: importa filhos com lookup já atualizado

Arquivo: 07_importar_dados_lookup.sh

#!/bin/bash for arq in ./dados_importacao_lookup_corrigido/*.csv; do nome_base=$(basename "$arq" .csv) echo "Importando filhos: $nome_base" sf data import --sobjecttype "$nome_base" --files "$arq" done

