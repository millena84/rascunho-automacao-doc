import csv
import os

ARQUIVO_ORIGEM = './1_metadados/_DadoCustomMetadata_ref.csv'
ARQUIVO_CORRIGIDO = './1_metadados/_DadoCustomMetadata_ref_corrigido.csv'

# Garante que o diretório de saída existe
os.makedirs(os.path.dirname(ARQUIVO_CORRIGIDO), exist_ok=True)

print(f"📄 Lendo e validando: {ARQUIVO_ORIGEM}\n")

with open(ARQUIVO_ORIGEM, 'r', encoding='utf-8-sig') as f:
    linhas = f.readlines()

# Detectar delimitador real
delimitador = ',' if linhas[0].count(',') > linhas[0].count(';') else ';'
cabecalho = linhas[0].strip().split(delimitador)
esperado = len(cabecalho)
print(f"🔍 Delimitador detectado: '{delimitador}' com {esperado} colunas")

linhas_validas = [cabecalho]
linhas_descartadas = []

for i, linha in enumerate(linhas[1:], start=2):
    partes = linha.strip().split(delimitador)
    if len(partes) == esperado:
        linhas_validas.append(partes)
    else:
        linhas_descartadas.append((i, linha.strip(), len(partes)))

with open(ARQUIVO_CORRIGIDO, 'w', newline='', encoding='utf-8-sig') as out:
    writer = csv.writer(out, delimiter=delimitador, quoting=csv.QUOTE_MINIMAL, lineterminator='\r\n')
    for linha in linhas_validas:
        writer.writerow([col.strip().replace('\n', ' ').replace('\r', ' ') for col in linha])

print(f"\n✅ CSV corrigido salvo como: {ARQUIVO_CORRIGIDO}")
print(f"✔️ Total de linhas válidas: {len(linhas_validas)-1}")
print(f"❌ Total de linhas descartadas: {len(linhas_descartadas)}")

if linhas_descartadas:
    print("\n🔎 Linhas problemáticas:")
    for i, conteudo, qtd in linhas_descartadas[:10]:
        print(f" - Linha {i} ({qtd} colunas): {conteudo}")
