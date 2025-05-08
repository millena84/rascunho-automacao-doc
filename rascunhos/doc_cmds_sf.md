# 📘 Comandos `sf` seguros para uso em organizações Salesforce produtivas

## ✅ Objetivo

Este guia lista os comandos da Salesforce CLI (`sf`) que **NÃO causam impacto em dados ou metadados**, sendo **seguros para uso em ambientes produtivos**. São comandos de **consulta, leitura ou exportação**, usados para diagnóstico, análise e auditoria.

> ⚠️ **Atenção:** este guia considera **somente comandos da `sf` CLI** (nova geração da CLI Salesforce). A antiga `sfdx` será descontinuada.

---

## 📌 Premissas

1. Ter a [Salesforce CLI (`sf`)](https://developer.salesforce.com/tools/sfcli) instalada.
2. Ter uma **org autenticada** (produção, sandbox, dev ou playground).
3. Usar o alias correto da org (`--target-org` ou `-o`) em todos os comandos.
4. Preferencialmente usar uma versão atualizada da CLI:

   ```bash
   sf update
   ```

---

## ✅ Comandos seguros

### 1. 🔎 Listar metadados disponíveis

```bash
sf org list metadata --target-org <alias>
```

**Descrição**: Lista os metadados da organização (componentes como `CustomObject`, `ApexClass`, etc).

> Exemplo:

```bash
sf org list metadata --target-org prodOrg
```

🔗 Docs: [https://developer.salesforce.com/docs/atlas.en-us.sf\_cli\_reference.meta/sf\_cli\_reference/cli\_reference\_org\_metadata\_list.htm](https://developer.salesforce.com/docs/atlas.en-us.sf_cli_reference.meta/sf_cli_reference/cli_reference_org_metadata_list.htm)

---

### 2. 📅 Retrieve (apenas leitura de metadados)

```bash
sf project retrieve start --metadata <tipo>:<nome> --target-org <alias>
```

**Descrição**: Recupera metadados da organização e os grava localmente no projeto. Sem alterações na org.

> Exemplo:

```bash
sf project retrieve start --metadata CustomObject:Account --target-org prodOrg
```

🔗 Docs: [https://developer.salesforce.com/docs/atlas.en-us.sf\_cli\_reference.meta/sf\_cli\_reference/cli\_reference\_project\_retrieve\_start.htm](https://developer.salesforce.com/docs/atlas.en-us.sf_cli_reference.meta/sf_cli_reference/cli_reference_project_retrieve_start.htm)

---

### 3. 📊 Consultar dados (SOQL)

```bash
sf data query --query "<SOQL>" --target-org <alias>
```

**Descrição**: Executa uma consulta SOQL e exibe os dados no terminal (ou exporta em CSV/JSON com `--output`).

> Exemplo:

```bash
sf data query --query "SELECT Id, Name FROM Account LIMIT 10" --target-org prodOrg
```

🔗 Docs: [https://developer.salesforce.com/docs/atlas.en-us.sf\_cli\_reference.meta/sf\_cli\_reference/cli\_reference\_data\_query.htm](https://developer.salesforce.com/docs/atlas.en-us.sf_cli_reference.meta/sf_cli_reference/cli_reference_data_query.htm)

---

### 4. 📁 Exportar dados em árvore (ideal para dev/teste)

```bash
sf data export tree --query "<SOQL>" --prefix <prefix> --output-dir <dir> --target-org <alias>
```

**Descrição**: Exporta dados relacionados em estrutura hierárquica. Pode usar para clonar dados de produção para teste (atenção à LGPD).

> Exemplo:

```bash
sf data export tree --query "SELECT Id, Name, (SELECT Id, LastName FROM Contacts) FROM Account LIMIT 5" --prefix prodSample --output-dir data --target-org prodOrg
```

🔗 Docs: [https://developer.salesforce.com/docs/atlas.en-us.sf\_cli\_reference.meta/sf\_cli\_reference/cli\_reference\_data\_export\_tree.htm](https://developer.salesforce.com/docs/atlas.en-us.sf_cli_reference.meta/sf_cli_reference/cli_reference_data_export_tree.htm)

---

### 5. 📋 Ver detalhes da organização

```bash
sf org display --target-org <alias>
```

**Descrição**: Mostra informações da org (tipo, edição, usuário logado, namespace, etc).

> Exemplo:

```bash
sf org display --target-org prodOrg
```

🔗 Docs: [https://developer.salesforce.com/docs/atlas.en-us.sf\_cli\_reference.meta/sf\_cli\_reference/cli\_reference\_org\_display.htm](https://developer.salesforce.com/docs/atlas.en-us.sf_cli_reference.meta/sf_cli_reference/cli_reference_org_display.htm)

---

### 6. 📂 Ver projetos conectados (ambientes, etc)

```bash
sf env list
```

**Descrição**: Lista todos os ambientes (orgs) autenticados com seus aliases.

🔗 Docs: [https://developer.salesforce.com/docs/atlas.en-us.sf\_cli\_reference.meta/sf\_cli\_reference/cli\_reference\_env\_list.htm](https://developer.salesforce.com/docs/atlas.en-us.sf_cli_reference.meta/sf_cli_reference/cli_reference_env_list.htm)

---

## 🚨 Comandos que NÃO DEVEM ser usados diretamente em produção

| Comando                   | Ação                        | Motivo                        |
| ------------------------- | --------------------------- | ----------------------------- |
| `sf project deploy start` | Envia metadados para a org  | Pode sobrescrever componentes |
| `sf data delete`          | Apaga registros             | Perda irreversível de dados   |
| `sf data update`          | Altera registros            | Pode causar inconsistência    |
| `sf data create`          | Cria registros              | Pode poluir a base            |
| `sf apex run`             | Executa código Apex         | Pode causar lógica imprevista |
| `sf functions deploy`     | Envia funções para execução | Pode alterar dados            |

---

## 🧠 Dicas de uso seguro

* 🗌 Sempre cheque o alias antes:

```bash
sf org display --target-org prodOrg
```

* 🚩 Evite comandos `deploy`, `update`, `create`, `delete` em produção.
* 💡 Coloque confirmações visuais em scripts (`read -p`).
* 📊 Use comandos de exportação para análises fora do Salesforce.
* 🔍 Prefira ambientes de sandbox ou scratch org para testes destrutivos.

---

## 🔗 Links úteis

* 📘 Documentação oficial SF CLI:
  [https://developer.salesforce.com/tools/sfcli](https://developer.salesforce.com/tools/sfcli)

* 📦 Comandos CLI por categoria:
  [https://developer.salesforce.com/docs/atlas.en-us.sf\_cli\_reference.meta/sf\_cli\_reference/cli\_reference\_command\_list.htm](https://developer.salesforce.com/docs/atlas.en-us.sf_cli_reference.meta/sf_cli_reference/cli_reference_command_list.htm)

* 🛠️ Comparação `sf` vs `sfdx`:
  [https://developer.salesforce.com/docs/atlas.en-us.sfdx\_cli\_reference.meta/sfdx\_cli\_reference/migration\_to\_sf\_cli.htm](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/migration_to_sf_cli.htm)

---

## ✅ Última revisão

📅 Data: 08/05/2025
🔧 CLI Version recomendada: `sf v2.43.0` ou superior
🔍 Revisor técnico: Jubileu (Especialista Salesforce com 25 anos de experiência 🧐)
