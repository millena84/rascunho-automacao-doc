import os
import shutil
from datetime import datetime

# Configuração
base_default_dir = r"C:\Users\mille\projetosSf\model_project_sf_it-bc\force-app\main\default"

# Timestamp para nome da pasta
timestamp = datetime.now().strftime("%y%m%d-%H-%M")
backup_dir = os.path.join(os.path.dirname(base_default_dir), f"default_backup_{timestamp}")

# Cria a pasta de backup, se necessário
os.makedirs(backup_dir, exist_ok=True)

print("📦 Iniciando backup...")
print(f"📂 Origem : {base_default_dir}")
print(f"📁 Backup : {backup_dir}")
print()

# Valida se a pasta existe
if not os.path.isdir(base_default_dir):
    print(f"❌ Pasta de origem não encontrada: {base_default_dir}")
    exit(1)

# Copia o conteúdo interno da pasta default (não a própria)
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
    print("⚠️ Nenhum arquivo encontrado para copiar.")
else:
    print(f"\n🎉 Backup concluído! Total de arquivos copiados: {copiados}")
    print(f"📁 Conteúdo salvo em: {backup_dir}")
