import os
import xml.etree.ElementTree as ET

DIR_ENTRADA = "./2_entrada_xml"
DIR_SAIDA = "./3_saida_xml"
CSV_SAIDA = f"{DIR_SAIDA}/listaCustomAlteracao.csv"

os.makedirs(DIR_SAIDA, exist_ok=True)
print("🔁 Atualizando XMLs mantendo a ordem original com precisão linha a linha...")

with open(CSV_SAIDA, encoding="utf-8") as f:
    linhas = f.readlines()[1:]  # ignora cabeçalho

for linha in linhas:
    if not linha.strip():
        continue
    # arquivo = linha.strip().split(";")[0].strip().replace("\\", "/").replace(" ", "")
    partes = linha.strip().split(";")
    arquivo = partes[0].strip().replace("\\", "/").replace(" ", "")
    formato_tabela = partes[4].strip()
    canal_tabela = partes[5].strip()

    input_path = os.path.normpath(os.path.join(DIR_ENTRADA, arquivo))
    output_path = os.path.normpath(os.path.join(DIR_SAIDA, arquivo))


    if not os.path.exists(input_path):
        print(f"⚠️ Arquivo não encontrado: {input_path}")
        continue

    tree = ET.parse(input_path)
    root = tree.getroot()

    for valores in root.findall("./{*}values"):
        campo = valores.find("./{*}field")
        valor = valores.find("./{*}value")
        if campo is not None and valor is not None:
            if "Canal__c" in campo.text:
                valor.text = canal_tabela
            elif "Formato__c" in campo.text:
                valor.text = formato_tabela

    tree.write(output_path, encoding="utf-8", xml_declaration=True)
    print(f"✅ Atualizado: {arquivo}")

print(f"🏁 Finalizado. XMLs salvos em: {DIR_SAIDA}")
