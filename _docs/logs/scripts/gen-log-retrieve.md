# notas


## sugestoes para depois:
_docs/
  |_ _updt-sand-dev-aliasOrg/
      |_ alterations_log.json
      |_ alterations_log.md

## interação:
$ ./gerar_log_retrieve.sh

Alterações detectadas:
- objects/Account.object-meta.xml
- validationRules/AccountCPFCheck.validationRule-meta.xml

Digite um comentário para esta alteração:

    > Criação de campo CPF obrigatório e ajuste na Account

Digite seu RACF ou Nome:

    > xxxx

Log atualizado em logs/alterations_log.json
Resumo:
Data: 29/04/2025 21:42
Responsável: mferreira
Componentes alterados: 2

## ideia modelo .json

    {
      "dataHora": "2025-04-29 21:42",
      "responsavel": "mferreira",
      "comentario": "Ajuste de regra de validação em Account e novo campo em Contact",
      "componentes": [
        "objects/Account.object-meta.xml",
        "objects/Contact.object-meta.xml",
        "validationRules/AccountCPFCheck.validationRule-meta.xml"
      ]
    }
