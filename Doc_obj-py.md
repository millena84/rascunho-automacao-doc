
# 🧾 Documentador de Objetos Salesforce (`Documentador_obj.py`)

## 📌 Objetivo

Este script tem como finalidade gerar **documentação técnica automatizada** de objetos e componentes do Salesforce Platform a partir de metadados XML. Ele centraliza as definições de estrutura em dois arquivos JSON, tornando a solução extensível e reutilizável em qualquer projeto Salesforce com versionamento de metadados.

---

## 📂 Estrutura Geral

### 📁 Arquivo Principal: `Documentador_obj.py`

Este programa realiza as seguintes funções:

1. Converte caminhos estilo Git Bash para o padrão do Windows.
2. Lê arquivos `.object-meta.xml` e `.field-meta.xml`.
3. Extrai e estrutura informações como:
   - API Name
   - Label
   - Tipo de Campo
   - Campo de Ajuda
   - Obrigatoriedade
   - Fórmulas
   - TrackHistory
   - ValueSet
4. Busca referências cruzadas em diretórios da estrutura de projeto.
5. Classifica e agrupa referências encontradas por tipo.
6. Gera arquivo `.md` contendo toda a documentação.

---

## 📁 Arquivos de Configuração

### 🔧 `_config_objeto_Documentacao.json`

Define quais objetos devem ser documentados, como estão relacionados e qual o caminho do projeto.

| Campo | Descrição |
|-------|-----------|
| `basePath` | Caminho do repositório onde estão os metadados Salesforce |
| `outputPath` | Caminho onde o arquivo `.md` gerado será salvo |
| `customObjects` | Lista dos objetos principais a serem documentados |
| `demaisObjetos` | Objetos auxiliares e dependentes |
| `DocCmdtCamposCanalFormato.infoEspecifica` | Nome amigável e descrição do grupo de objetos |
| `DocCmdtCamposCanalFormato.aplicativosSF` | Lista de aplicações Salesforce em que o objeto aparece |
| `infoCmdt` | Nome técnico do objeto e prefixo usado nos registros |
| `infoDesconsiderar` | Palavras-chave a serem ignoradas |
| `infoTabsEnvolvidasCmdt` | Campos que fazem relação com outros objetos |
| `ordemMd` | Ordem de exibição das seções no arquivo de documentação |

---

### 🔧 `_config_mapa_componentesSF.json`

Contém o mapeamento dos tipos de metadados para pastas do repositório de código.

| Tipo de Componente | Pasta Correspondente |
|--------------------|----------------------|
| `ApexClass` | `classes` |
| `CustomMetadata` | `customMetadata` |
| `Flow` | `flows` |
| `LightningComponentBundle` | `lwc` |
| `PermissionSet` | `permissionsets` |
| *(e muitos outros tipos padrão Salesforce)* | ... |

---

## 🧠 Funcionalidades do Código

### 🔁 Conversão de Caminho Git Bash

```python
def path_gitbash_para_windows(caminho):
    ...
```
Converte caminhos tipo `/c/Users/...` para `C:\Users\...`.

---

### 🔍 Busca por Referências de Objetos

```python
def buscar_referencias(objeto_api, base_path):
    ...
```
Varre todos os arquivos `.cls`, `.js`, `.xml` no repositório buscando ocorrências do nome do objeto.

---

### 🧩 Parse dos Campos do Objeto

```python
def parse_campos_objeto(obj_path):
    ...
```
Lê campos definidos nos XMLs e coleta informações técnicas relevantes (inclusive ValueSet e fórmulas).

---

### 🖊️ Geração de Markdown

```python
def gerar_documentacao_objeto(config, objeto):
    ...
```
Cria o conteúdo final da documentação, agrupando campos, metadados e referências externas por tipo de componente.

---

## ▶️ Execução

Execute com:

```bash
python Documentador_obj.py
```

---

## 📁 Saída

- Um arquivo `.md` por objeto especificado no JSON.
- Conteúdo tabulado com metainformações técnicas e seções organizadas por tipo de metadado.

---

## 💡 Recomendações

- Utilize em esteiras de documentação contínua (CI).
- Pode ser acoplado ao Flosum, DevOps Center ou GitHub Actions.
- Para novos objetos, atualize apenas os JSONs.

---

## 👩‍💻 Autor(a)

Millena Ferreira dos Reis  
*Engenheira de Software | Especialista Salesforce | Mentora Técnica*
