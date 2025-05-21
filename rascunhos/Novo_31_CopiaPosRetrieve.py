import os import shutil import json from datetime import datetime

=== Script python: 31_copia_arquivos_pos_retrieve.py ===

Esse script copia, para dentro de diretórios usados no processo,

os arquivos a serem usados para alteração em lote.

=== Parâmetros e leitura do JSON ===

ARQ_EXECUCAO = "/c/Users/mille/projetosSf/_configUtil.json" ARQ_EXECUCAO_WIN = os.popen(f"cygpath -w {ARQ_EXECUCAO}").read().strip() timestamp = datetime.now().strftime("%d/%m/%Y - %H:%M:%S")

=== Função para converter caminhos estilo Git Bash para Windows ===

def path_gitbash_para_windows(caminho): if caminho.startswith("/"): partes = caminho.strip("/").split("/", 1) if len(partes) == 2 and len(partes[0]) == 1: drive, resto = partes return os.path.abspath(os.path.normpath(f"{drive.upper()}:/{resto}")) return os.path.abspath(os.path.normpath(caminho))

with open(ARQ_EXECUCAO_WIN, "r", encoding="utf-8") as f: config = json.load(f)

avaliacao_cfg = config.get("infoEspecificaProcessos", {}).get("avaliacaoCustomMdt", [{}])[0]

origem_base = path_gitbash_para_windows(config.get("infoEspecificaProcessos", {}).get("retrieve", [{}])[0].get("dirPosixRef", "")) destino_base = path_gitbash_para_windows(avaliacao_cfg.get("infoCopiaLocal", {}).get("dirPosixCompPrincipal", "")) filtro_nome = avaliacao_cfg.get("infoCopiaLocal", {}).get("filtroNomeArquivosAlvo", "").strip() dir_componente = avaliacao_cfg.get("infoCopiaLocal", {}).get("dirComponente", "").strip()

if not filtro_nome or not dir_componente: print(f"❌ Campos obrigatórios ausentes: 'filtroNomeArquivosAlvo' ou 'dirComponente'") exit(1)

Garante que dir_componente não sobrescreva caminhos

dir_componente = dir_componente.lstrip("\/")

pasta_origem = os.path.normpath(os.path.join(origem_base, dir_componente))

Timestamp para nome seguro

nome_seguro = f"{filtro_nome}{datetime.now().strftime('%Y%m%d-%H%M%S')}".replace("/", "").replace("\", "_")

pasta_destino_copias = os.path.join(destino_base, "9_entradas_xml_copias") pasta_destino_copia_versionada = os.path.join(pasta_destino_copias, f"Info_{nome_seguro}") pasta_destino_final = os.path.join(destino_base, "2_entrada_xml")

os.makedirs(pasta_destino_copia_versionada, exist_ok=True) os.makedirs(pasta_destino_copias, exist_ok=True) os.makedirs(pasta_destino_final, exist_ok=True)

print(f"\n📦 ➤ CÓPIA DOS ARQUIVOS DE CUSTOM METADATA A SEREM AVALIADOS PARA O DIRETÓRIO LOCAL") print(f"🕐 ➤ INÍCIO EXECUÇÃO: {timestamp}") print(f"📁 ➤ Origem Projeto SF: {origem_base}") print(f"📁 ➤ Origem (componentes): {pasta_origem}") print(f"📁 ➤ Destino (com todas as versões): {pasta_destino_copias}") print(f"📁 ➤ Destino (com os extraídos na EXECUÇÃO): {pasta_destino_copia_versionada}") print(f"📁 ➤ Destino (final): {pasta_destino_final}") print(f"🔎 ➤ Filtro considerado: {filtro_nome}\n")

=== Logs Iniciais ===

print(f"🔍 ➤ Procurando arquivos com: {filtro_nome}") print(f"🔍 ➤ Origem : {pasta_origem}") print(f"🔍 ➤ Destino (cópias) : {pasta_destino_copias}") print(f"🔍 ➤ Destino (final)  : {pasta_destino_final}\n")

=== Verifica origem ===

if not os.path.isdir(pasta_origem): print(f"❌ Pasta de origem não encontrada: {pasta_origem}") exit(1)

=== Cópia dos arquivos ===

copiados = 0 for root, _, files in os.walk(pasta_origem): for file in files: if filtro_nome in file: origem_path = os.path.join(root, file) caminho_relativo = os.path.relpath(origem_path, pasta_origem)

destino_path = os.path.join(pasta_destino_copia_versionada, caminho_relativo)
        os.makedirs(os.path.dirname(destino_path), exist_ok=True)
        shutil.copy2(origem_path, destino_path)
        print(f"📁 ➕ Copiado para pasta intermediária: {caminho_relativo}")

        destino_path = os.path.join(pasta_destino_final, caminho_relativo)
        os.makedirs(os.path.dirname(destino_path), exist_ok=True)
        shutil.copy2(origem_path, destino_path)
        print(f"📁 ✅ Copiado para 'oficial'         : {caminho_relativo}")

        copiados += 1

=== Finalização ===

print() if copiados == 0: print(f"⚠️ Nenhum arquivo contendo '{filtro_nome}' foi encontrado.") else: print(f"✅ {copiados} arquivo(s) copiado(s) com sucesso.") print(f"📌 Conteúdo salvo em: {pasta_destino_final}")

