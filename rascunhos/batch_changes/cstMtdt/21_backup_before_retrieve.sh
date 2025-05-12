#!/bin/bash

CONFIG_FILE="./11_extract_org_metadata.json"
MAP_FILE="./mapa_pastas_componentes.json"

# Validar se arquivos existem
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Arquivo de configuração $CONFIG_FILE não encontrado."
  exit 1
fi

if [ ! -f "$MAP_FILE" ]; then
  echo "❌ Arquivo de mapeamento $MAP_FILE não encontrado."
  exit 1
fi

# Lê a base default do projeto
BASE_DEFAULT_DIR=$(node -e "
  try {
    const config = require('$CONFIG_FILE');
    console.log(config.diretorioProjetosSF);
  } catch (e) {
    console.error('❌ Erro ao obter diretorioProjetosSF:', e.message);
    process.exit(1);
  }
")

# Monta pasta de backup
TIMESTAMP=$(date +"%y%m%d-%H-%M")
BASE_BACKUP_DIR=\"\${BASE_DEFAULT_DIR/default/default_backup_$TIMESTAMP}\"

# Remove aspas extras de substituição
BASE_BACKUP_DIR=$(eval echo $BASE_BACKUP_DIR)

echo "📦 Iniciando backup..."
echo "📂 Origem: $BASE_DEFAULT_DIR"
echo "📁 Backup: $BASE_BACKUP_DIR"
echo ""

mkdir -p "$BASE_BACKUP_DIR"

# Loop via node para listar tipoComponente, filtros e pasta destino
node <<EOF
const fs = require('fs');
const path = require('path');
const config = require('$CONFIG_FILE');
const map = require('$MAP_FILE');

const baseDefaultDir = config.diretorioProjetosSF;
const backupDir = "$BASE_BACKUP_DIR";

if (!fs.existsSync(baseDefaultDir)) {
  console.error('❌ Diretório de origem não existe:', baseDefaultDir);
  process.exit(1);
}

function findFilesRecursive(dir, match) {
  const filesFound = [];
  if (!fs.existsSync(dir)) return filesFound;

  const items = fs.readdirSync(dir, { withFileTypes: true });
  for (const item of items) {
    const fullPath = path.join(dir, item.name);
    if (item.isDirectory()) {
      filesFound.push(...findFilesRecursive(fullPath, match));
    } else if (item.name.includes(match)) {
      filesFound.push(fullPath);
    }
  }
  return filesFound;
}

for (const comp of config.componentes) {
  const tipo = comp.tipoComponente;
  const pastaRelativa = map[tipo];

  if (!pastaRelativa) {
    console.warn(\`⚠️  Tipo de componente não mapeado: \${tipo}\`);
    continue;
  }

  const origemBase = path.join(baseDefaultDir, pastaRelativa);

  for (const filtro of comp.filtros) {
    const encontrados = findFilesRecursive(origemBase, filtro);

    if (encontrados.length === 0) {
      console.log(\`🔍 Nenhum arquivo encontrado com filtro '\${filtro}' em '\${origemBase}'\`);
    }

    for (const arq of encontrados) {
      const caminhoRelativo = path.relative(baseDefaultDir, arq);
      const destino = path.join(backupDir, caminhoRelativo);
      fs.mkdirSync(path.dirname(destino), { recursive: true });
      fs.copyFileSync(arq, destino);
      console.log(\`✅ Backup: \${caminhoRelativo}\`);
    }
  }
}
EOF

echo ""
echo "🎉 Backup finalizado com sucesso!"
echo "📁 Arquivos copiados para: $BASE_BACKUP_DIR"
