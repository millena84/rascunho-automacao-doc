import os
import shutil
import json
from datetime import datetime

# Caminho original da pasta Salesforce (fornecido fixo)
base_default_dir = r"C:\Users\mille\projetosSF\model_project_sf_it-bc\force-app\main\default"

# Timestamp para controle e exibição
timestamp = datetime.now().strftime("%Y%m%d-%H-%M")
passo_exec = datetime.now().strftime("%Y%m%d-%H-%M")

# Carrega o caminho do JSON
json_path = "configuracoes_execucao.json"  # ajuste se necessário
with open(json_path, "r", encoding="utf-8") as f:
    config = json.load(f)

# Caminho base vindo do JSON
destino_base = config.get("diretorioAlteracaoCustomMtdLote")

if not destino_base:
    print("❌ Caminho 'diretorioAlteracaoCustomMtdLote' não encontrado no JSON.")
    exit(1)

# Caminho final de backup: <diretorioAlteracaoCustomMtdLote>/bckp_preRet
backup_dir = os.path.join(destino_base, "bckp_preRet")

print()
print(f"🚀 INICIO PROCESSO BACKUP     {passo_exec}")
print(f"📂 Origem: {base_default_dir}")
print(f"📂 Backup: {backup_dir}")
print()

# Valida se a pasta de origem existe
if not os.path.isdir(base_default_dir):
    print(f"❌ Pasta de origem não encontrada: {base_default_dir}")
    print(f"❌ FIM EXECUCAO: {passo_exec}")
    exit(1)

# Cria a pasta de destino se necessário
os.makedirs(backup_dir, exist_ok=True)

# Copia arquivos internos (sem copiar a própria raiz)
copiados = 0
for root, dirs, files in os.walk(base_default_dir):
    for file in files:
        origem_path = os.path.join(root, file)
        caminho_relativo = os.path.relpath(origem_path, base_default_dir)
        destino_path = os.path.join(backup_dir, caminho_relativo)

        os.makedirs(os.path.dirname(destino_path), exist_ok=True)
        shutil.copy2(origem_path, destino_path)

        print(f"✅ Copiado: {caminho_relativo}")
        copiados += 1

if copiados == 0:
    print("⚠️  Nenhum arquivo encontrado para copiar.")
else:
    print(f"\n📦 Backup concluído! Total de arquivos copiados: {copiados}")
    print(f"📁 Conteúdo salvo em: {backup_dir}")

print(f"✅ FIM EXECUCAO (passo exec): {passo_exec}")
