import re
import os

def atualizar_valores_xml_com_regex(caminho_entrada, canal_novo, formato_novo, destino):
    with open(caminho_entrada, 'r', encoding='utf-8') as f:
        conteudo = f.read()

    # Substitui valor de Canal__c
    canal_regex = re.compile(
        r'(<values>\s*<field>\s*Canal__c\s*</field>\s*<value>)(.*?)(</value>\s*</values>)',
        re.DOTALL | re.IGNORECASE
    )
    conteudo, subs1 = canal_regex.subn(rf'\1{canal_novo}\3', conteudo)

    # Substitui valor de Formato__c
    formato_regex = re.compile(
        r'(<values>\s*<field>\s*Formato__c\s*</field>\s*<value>)(.*?)(</value>\s*</values>)',
        re.DOTALL | re.IGNORECASE
    )
    conteudo, subs2 = formato_regex.subn(rf'\1{formato_novo}\3', conteudo)

    if subs1 == 0 or subs2 == 0:
        print(f'⚠️ Não encontrou Canal__c ou Formato__c em: {os.path.basename(caminho_entrada)}')
    else:
        os.makedirs(os.path.dirname(destino), exist_ok=True)
        with open(destino, 'w', encoding='utf-8', newline='\n') as f:
            f.write(conteudo)
        print(f'✅ Atualizado sem quebrar estrutura: {os.path.basename(destino)}')
