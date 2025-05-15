# Script: documentador_cmdt.py
# Autor: Jubileu (Salesforce Specialist)
# Descrição: Gera documentação em Markdown para um Custom Metadata Type (CMDT) e seus relacionamentos
# Requisitos: Python 3. Sem dependências externas

import os
import xml.etree.ElementTree as ET
import json

# --- Funções auxiliares ---
def parse_field_metadata(file_path):
    tree = ET.parse(file_path)
    root = tree.getroot()
    ns = {'sf': 'http://soap.sforce.com/2006/04/metadata'}

    field = {
        'api_name': root.findtext('sf:fullName', default='', namespaces=ns),
        'label': root.findtext('sf:label', default='', namespaces=ns),
        'type': root.findtext('sf:type', default='', namespaces=ns),
        'description': root.findtext('sf:description', default='', namespaces=ns),
        'inlineHelpText': root.findtext('sf:inlineHelpText', default='', namespaces=ns),
        'required': root.findtext('sf:required', default='false', namespaces=ns) == 'true',
        'length': root.findtext('sf:length', default='', namespaces=ns),
        'defaultValue': root.findtext('sf:defaultValue', default='', namespaces=ns),
        'valueSet': []
    }

    value_set = root.find('sf:valueSet/sf:valueSetDefinition', namespaces=ns)
    if value_set is not None:
        for val in value_set.findall('sf:value', namespaces=ns):
            field['valueSet'].append(val.findtext('sf:label', default='', namespaces=ns))

    return field

def document_fields(fields):
    lines = ["| Campo API Name | Label | Tipo | Obrigatório | Descrição / Ajuda |",
             "|----------------|-------|------|-------------|--------------------|"]
    for f in fields:
        desc = f.get('description') or f.get('inlineHelpText') or ''
        lines.append(f"| {f['api_name']} | {f['label']} | {f['type']} | {'✅' if f['required'] else '❌'} | {desc} |")
    return '\n'.join(lines)

def generate_markdown(config):
    base_path = config.get('basePath', '.')
    output_path = os.path.join(base_path, config.get('outputPath', './docs'))
    os.makedirs(output_path, exist_ok=True)

    mdt = config['metadataType']
    object_path = os.path.join(base_path, f"objects/{mdt}/fields")

    campos = []
    for fname in os.listdir(object_path):
        if fname.endswith('.xml'):
            campos.append(parse_field_metadata(os.path.join(object_path, fname)))

    doc = []
    doc.append(f"# 🧩 Custom Metadata Type: {mdt}\n")
    doc.append("## 📘 O que é Custom Metadata?")
    doc.append("""
Custom Metadata Types (CMDT) permitem armazenar metadados customizados que podem ser usados em tempo de execução em Apex, Fluxos e Lightning Components.

**Recomendações de uso:**
- Quando você precisa de dados configuráveis que mudam raramente e não são sensíveis a segurança
- Quando os dados precisam ser incluídos em pacotes e migrados por deploy

**Evite usar CMDT quando:**
- Os dados forem mutáveis em tempo de execução por usuários
- Houver necessidade de grandes volumes (use Custom Settings ou objetos customizados comuns)

**Links úteis:**
- [Documentação Oficial CMDT](https://developer.salesforce.com/docs/atlas.en-us.236.0.apexref.meta/apexref/apex_class_Metadata_Operations.htm)
- [Trailhead - Custom Metadata](https://trailhead.salesforce.com/content/learn/modules/custom_metadata)
- [Comparativo: CMDT vs Custom Settings](https://help.salesforce.com/s/articleView?id=sf.custommetadatatypes_about.htm)
""")

    doc.append("\n---\n\n## 🗃️ Estrutura de Campos\n")
    doc.append(document_fields(campos))

    # Relacionamentos
    doc.append("\n---\n\n## 🔗 Tabelas Relacionadas\n")
    for rel in config.get('relatedObjects', []):
        rel_path = os.path.join(base_path, f"objects/{rel}/fields")
        doc.append(f"### {rel}\n")
        rel_fields = []
        for fname in os.listdir(rel_path):
            if fname.endswith('.xml'):
                rel_fields.append(parse_field_metadata(os.path.join(rel_path, fname)))
        doc.append(document_fields(rel_fields))
        doc.append("\n")

    # Referencias externas
    doc.append("\n---\n\n## ⚙️ Uso em Apex\n```
// Exemplo de chamada em Apex
MyCustomService.loadFromMetadata('ValorX');
```")
    doc.append("\n## 🖼️ Uso em LWC\n```
import getMetadata from '@salesforce/apex/MyCustomService.getMetadata';
```")
    doc.append("\n## 📎 Outros Usos\n- Fluxos (Flow)")

    # Salvando
    out_file = os.path.join(output_path, f"{mdt}.md")
    with open(out_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(doc))

    print(f"✅ Documentação gerada em: {out_file}")

# --- Execução ---
if __name__ == '__main__':
    with open('config_cmdt.json', 'r', encoding='utf-8') as f:
        config = json.load(f)
    generate_markdown(config)
