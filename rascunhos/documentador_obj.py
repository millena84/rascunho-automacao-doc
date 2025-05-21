# Script: documentador_objetos.py
# Autor: Jubileu (Salesforce Specialist)
# Descrição: Gera documentação em Markdown para objetos customizados Salesforce, com referências cruzadas
# Requisitos: Python 3. Sem dependências externas

import os
import xml.etree.ElementTree as ET
import json

# Mapa de pastas por tipo de componente (deve ser alimentado via arquivo externo ou inline se desejado)
with open('21_mapa_pastas_componentes.json', 'r', encoding='utf-8') as f:
    COMPONENT_MAP = json.load(f)

# Função para buscar diretórios relacionados ao objeto

def buscar_referencias(objeto_api, base_path):
    referencias = []
    for root, _, files in os.walk(base_path):
        for file in files:
            if file.endswith('.xml') or file.endswith('.js') or file.endswith('.cls'):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        conteudo = f.read()
                        if objeto_api in conteudo:
                            referencias.append(path)
                except:
                    continue
    return referencias

def parse_campos_objeto(obj_path):
    campos = []
    ns = {'sf': 'http://soap.sforce.com/2006/04/metadata'}
    for file in os.listdir(obj_path):
        if file.endswith('.xml'):
            xml = ET.parse(os.path.join(obj_path, file))
            root = xml.getroot()
            campo = {
                'api_name': root.findtext('sf:fullName', default='', namespaces=ns),
                'label': root.findtext('sf:label', default='', namespaces=ns),
                'type': root.findtext('sf:type', default='', namespaces=ns),
                'required': root.findtext('sf:required', default='false', namespaces=ns) == 'true',
                'trackHistory': root.findtext('sf:trackHistory', default='false', namespaces=ns) == 'true',
                'trackFeed': root.findtext('sf:trackFeedHistory', default='false', namespaces=ns) == 'true',
                'formula': root.findtext('sf:formula', default='', namespaces=ns),
                'valueSet': []
            }
            value_set = root.find('sf:valueSet/sf:valueSetDefinition', namespaces=ns)
            if value_set is not None:
                for val in value_set.findall('sf:value', namespaces=ns):
                    label = val.findtext('sf:label', default='', namespaces=ns)
                    fullName = val.findtext('sf:fullName', default='', namespaces=ns)
                    is_default = val.findtext('sf:default', default='false', namespaces=ns) == 'true'
                    campo['valueSet'].append({
                        'label': label,
                        'fullName': fullName,
                        'default': is_default
                    })
            campos.append(campo)
    return campos

def documentar_campos(campos):
    doc = ["| Campo API Name | Label | Tipo | Obrigatório | Fórmula | Domínios | Histórico | Chatter |",
           "|----------------|-------|------|-------------|---------|----------|-----------|---------|"]
    for f in campos:
        dominios = ", ".join([v['label'] for v in f['valueSet']]) if f['valueSet'] else "-"
        doc.append(f"| {f['api_name']} | {f['label']} | {f['type']} | {'✅' if f['required'] else '❌'} | {f['formula'] or '-'} | {dominios} | {'✅' if f['trackHistory'] else '❌'} | {'✅' if f['trackFeed'] else '❌'} |")
    return '\n'.join(doc)

def documentar_dominios(campos):
    doc = ["## 🧾 Detalhamento de Domínios de Picklists\n"]
    for f in campos:
        if f['type'] == 'Picklist' and f['valueSet']:
            doc.append(f"### {f['api_name']} - {f['label']}")
            doc.append("| Valor API | Label | Padrão |")
            doc.append("|-----------|--------|---------|")
            for val in f['valueSet']:
                doc.append(f"| {val['fullName']} | {val['label']} | {'✅' if val['default'] else ''} |")
            doc.append("\n")
    return '\n'.join(doc)

def gerar_documentacao_objeto(config):
    base_path = config.get('basePath', '.')
    output_path = os.path.join(base_path, config.get('outputPath', './docs'))
    os.makedirs(output_path, exist_ok=True)

    objeto = config['customObject']
    caminho_objeto = os.path.join(base_path, COMPONENT_MAP['CustomObject'], objeto, 'fields')
    campos = parse_campos_objeto(caminho_objeto)

    doc = [f"# 📄 Objeto: {objeto}\n"]
    doc.append("## 🧬 Campos\n")
    doc.append(documentar_campos(campos))
    doc.append("\n\n" + documentar_dominios(campos))

    # Buscando referências cruzadas em todo o projeto
    doc.append("\n---\n\n## 🔍 Referências ao Objeto no Projeto\n")
    refs = buscar_referencias(objeto, base_path)
    for ref in refs:
        doc.append(f"- `{ref}`")

    # Flexipages, listviews, etc.
    doc.append("\n---\n\n## 📑 Componentes Relacionados\n")
    for tipo, pasta in COMPONENT_MAP.items():
        if tipo in ["Layout", "ListView", "RecordType", "CompactLayout"]:
            dir_path = os.path.join(base_path, pasta)
            for root, _, files in os.walk(dir_path):
                for file in files:
                    if objeto in file:
                        doc.append(f"- `{os.path.join(root, file)}`")

    # Salvando Markdown
    doc_file = os.path.join(output_path, f"{objeto}.md")
    with open(doc_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(doc))

    print(f"✅ Documentação gerada para objeto {objeto}: {doc_file}")

# Execução
if __name__ == '__main__':
    with open('config_objeto.json', 'r', encoding='utf-8') as f:
        config = json.load(f)
    gerar_documentacao_objeto(config)
