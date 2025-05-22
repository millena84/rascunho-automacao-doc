import json
import csv
import os

# Caminhos esperados (ajuste conforme necessário)
ARQ_EXECUCAO = './_configUtil.json'
ARQ_TABELA = './1_metadados/_src_VincParamRefCustom.csv'
ARQ_XML = './1_metadados/_InfoParametrizadasInclCustom.csv'
ARQ_SAIDA = './3_saida_xml/listaVinculosPrecisamCustom.csv'

# Leitura do JSON de configuração
with open(ARQ_EXECUCAO, 'r', encoding='utf-8-sig') as f:
    config = json.load(f)

avaliacao = config["infoEspecificaProcessos"]["avaliacaoCustomMdt"][0]
customDeAvaliacao = avaliacao["customDeAvaliacao"]
infoCopiaLocal = avaliacao["infoCopiaLocal"]

# Decide estrutura e lógica da chave
if customDeAvaliacao == "CanalFormatoBrfMkt":
    estrutura = infoCopiaLocal["WW2_CamposCanalFormato__mdt"]["detalhamentoRelacaoCmdt"]
    campo_metadata = "WW2_CamposCanalFormato__mdt"
    chave_primaria = ("defCanal", "defFormato")
    campos_comuns = {
        "CampoRelacObjetoFilho": infoCopiaLocal[campo_metadata].get("defCampoRelacionamentoFilho", ""),
        "CampoRelacObjetoPai": infoCopiaLocal[campo_metadata].get("defCampoRelacionamentoObjetoPai", ""),
        "TelaUtilizada": infoCopiaLocal[campo_metadata].get("TelaUtilizada", "")
    }
elif customDeAvaliacao == "NegocioCanalAdicionalComum":
    estrutura = infoCopiaLocal["WW2_FormAdicionalComum__mdt"]["detalhamentoRelacaoCmdt"]
    campo_metadata = "WW2_FormAdicionalComum__mdt"
    chave_primaria = ("defNegocio", "defCanal")
    campos_comuns = {
        "CampoRelacObjetoFilho": "",  # Definir se necessário
        "CampoRelacObjetoPai": "",    # Definir se necessário
        "TelaUtilizada": infoCopiaLocal[campo_metadata].get("TelaUtilizada", "")
    }
else:
    raise ValueError("customDeAvaliacao não suportado.")

# Leitura dos registros XML existentes
with open(ARQ_XML, 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f, delimiter=';')
    registros_xml = set()
    for row in reader:
        canal = row.get("CanalXml", "").strip()
        formato = row.get("FormatoXml", "").strip()
        negocio = row.get("NegocioXml", "").strip()
        chave = (canal, formato) if customDeAvaliacao == "CanalFormatoBrfMkt" else (negocio, canal)
        registros_xml.add(chave)

# Leitura dos parâmetros esperados (tabela referência)
with open(ARQ_TABELA, 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f, delimiter=';')
    parametros_tab = []
    for row in reader:
        canal = row.get("CodCanalTab", "").strip()
        formato = row.get("FormatoTab", "").strip()
        negocio = row.get("TaxNegocioTab", "").strip()
        chave = (canal, formato) if customDeAvaliacao == "CanalFormatoBrfMkt" else (negocio, canal)
        parametros_tab.append(chave)

# Geração dos registros ausentes
saida = []
for detalhe in estrutura:
    chave_detalhe = tuple(detalhe.get(k, "").strip() for k in chave_primaria)
    if chave_detalhe in parametros_tab and chave_detalhe not in registros_xml:
        nome_arquivo = f"{campo_metadata}.{chave_detalhe[0]}_{chave_detalhe[1]}"
        label = f"{chave_detalhe[0]} - {chave_detalhe[1]}"
        linha = {
            "arquivo": nome_arquivo,
            "label": label,
            "CampoRelacObjetoFilho": detalhe.get("defCampoRelacionamentoFilho", campos_comuns["CampoRelacObjetoFilho"]),
            "CampoRelacObjetoPai": detalhe.get("defCampoRelacionamentoObjetoPai", campos_comuns["CampoRelacObjetoPai"]),
            "CamposTela": detalhe.get("defCamposTela", ""),
            "CamposObrigatorios": detalhe.get("defCamposObrigatorios", ""),
            "Canal": detalhe.get("defCanal", ""),
            "Formato": detalhe.get("defFormato", detalhe.get("defNegocio", "")),
            "Objeto": detalhe.get("defObjeto", ""),
            "TelaUtilizada": campos_comuns["TelaUtilizada"]
        }
        saida.append(linha)

# Escrita do arquivo final
os.makedirs(os.path.dirname(ARQ_SAIDA), exist_ok=True)
with open(ARQ_SAIDA, 'w', newline='', encoding='utf-8-sig') as f_out:
    writer = csv.DictWriter(f_out, fieldnames=saida[0].keys(), delimiter=';')
    writer.writeheader()
    writer.writerows(saida)

print(f"✔️ Arquivo gerado com {len(saida)} registros: {ARQ_SAIDA}")
