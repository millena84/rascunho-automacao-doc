import os
from pathlib import Path

# Caminhos de entrada
csv_path = "./3_saida_xml/listaParametrosCriacaoCustomMetadata_carga.csv"
template_path = "./1_metadados/BaseCustomMetadata.xml"
output_dir = "./_saida_python_xml"
os.makedirs(output_dir, exist_ok=True)

# Leitura do template
with open(template_path, encoding="utf-8") as f:
    template_content = f.read()

# Função de escape para XML
def escape_xml(texto):
    return (
        texto.replace("&", "&amp;")
             .replace("<", "&lt;")
             .replace(">", "&gt;")
             .replace('"', "&quot;")
             .replace("'", "&apos;")
             .replace("\n", "")
             .replace("\r", "")
             .strip()
    )

# Mapeamento entre colunas do CSV e os placeholders do template
chave_para_placeholder = {
    "label": "{{LABEL}}",
    "CampoRelacionamentoObjetoFilho": "{{CAMPO_REL_OBJ_FILHO}}",
    "CampoRelacionamentoObjetoPai": "{{CAMPO_REL_OBJ_PAI}}",
    "CamposTela": "{{CAMPOS_TELA}}",
    "Canal": "{{CAN}}",
    "Formato": "{{FOR}}",
    "Objeto": "{{OBJ_ESPEC}}",
    "TelaUtilizada": "{{TELA_USA}}"
}

# Leitura do CSV
with open(csv_path, encoding="utf-8") as f:
    linhas = f.readlines()

cabecalho = linhas[0].strip().split(";")
for linha in linhas[1:]:
    campos = linha.strip().split(";")
    if len(campos) < len(cabecalho):
        continue

    registro = dict(zip(cabecalho, campos))
    nome_arquivo = registro["NomeArquivo"].strip()
    conteudo = template_content

    for chave_csv, placeholder in chave_para_placeholder.items():
        valor = escape_xml(registro.get(chave_csv, ""))
        conteudo = conteudo.replace(placeholder, valor)

    with open(os.path.join(output_dir, nome_arquivo), "w", encoding="utf-8") as f_out:
        f_out.write(conteudo)

print(f"✅ Arquivos gerados em: {output_dir}")
