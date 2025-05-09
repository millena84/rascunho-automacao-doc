# ⚙️ Alteração de CustomMetadata em Lote

## 🧭 Visão Geral

Este processo permite a correção e equalização de configurações de diversos registros `CustomMetadata` em lote, sem a necessidade de edição manual via interface da Salesforce.

É útil para:
- Equalizar ambientes (Produção, UAT, Dev, etc.).
- Automatizar ajustes massivos nos metadados.
- Garantir consistência de parâmetros entre orgs.

---

## 🚩 Premissas

- Ter VSCode configurado para desenvolvimento Salesforce.
- Estar conectado em **produção** (para capturar dados atualizados).
- Estar conectado em **sandbox** (para deploy com Flosum ou outro pipeline).
- Ter o arquivo `11_extract_org_metadata.json` configurado com:
  - Diretório do projeto
  - Diretório do processo
  - Alias da org Salesforce na máquina

> **Opcional**: conexão com IT ou UAT para validação completa dos parâmetros.

---

## 🧩 Componentes Necessários

1. `10_extract_org_metadata.sh`  
   - Extrai localmente os metadados em arquivos `.csv` por tipo, conforme filtros do JSON.
   - Exige `11_extract_org_metadata.json` configurado corretamente.

2. `20_create_package_xml_retrieve.sh`  
   - Gera `package.xml` com base nos `.csv` gerados pela extração.

3. `30_org_retrieve.sh`  
   - Realiza o retrieve dos metadados definidos e faz unzip.

4. `40_extrai_info_tabela_usada_custom.sh`  
   - Gera `.csv` com os parâmetros da tabela de referência, para comparação com os `CustomMetadata`.

5. `50_extrai_info_custom_atual_mdt.sh`  
   - Extrai os `CustomMetadata` existentes para `.csv` de comparação.

6. `60_compara_defCustom_parametroTabela.sh`  
   - Identifica divergências entre o `CustomMetadata` e a referência.

7. `70_atualiza_customMetadata.sh`  
   - Gera `.csv` com os registros corrigidos, prontos para sobrescrever os atuais.

8. `80_cria_custommetadata.sh`  
   - Cria os novos XMLs de CustomMetadata com base nos `.csv`.

---

## 🧵 Passo a Passo Resumido

### 1. Extração dos Metadados

```bash
$ ./10_extract_org_metadata.sh
```

Gera `.csv` por tipo de metadado:
- `CustomObject`
- `CustomMetadata`
- `PermissionSet`

### 2. Criação do package.xml

```bash
$ ./20_create_package_xml_retrieve.sh
```

Gera:  
`./_retrieves/{timestamp}_package_retrieve.xml`

### 3. Retrieve dos metadados

```bash
$ ./30_org_retrieve.sh
```

Extrai os metadados e salva os diretórios descompactados na pasta `_retrieves`.

---

## 🔍 Comparação e Geração de Atualizações

### 4. Exportar a tabela de referência de parâmetros

Conectado em produção, gere um `.csv` da tabela de vínculo Canal x Formato.

### 5. Extrair CustomMetadata existente

```bash
$ ./50_extrai_info_custom_atual_mdt.sh
```

### 6. Comparar CustomMetadata x tabela de referência

```bash
$ ./60_compara_defCustom_parametroTabela.sh
```

### 7. Gerar CSV atualizado com valores corrigidos

```bash
$ ./70_atualiza_customMetadata.sh
```

---

## 🚀 Gerar XMLs de CustomMetadata para Deploy

```bash
$ ./80_cria_custommetadata.sh
```

Gera os arquivos `.xml` atualizados para deploy via pipeline, Flosum ou VSCode.

---

## 🗂️ Estrutura Esperada de Diretórios

```bash
/docs/
└── analise/
    └── estruturaAlteracaoLote/
        ├── entrada_xml/      # XMLs atuais dos CustomMetadata
        ├── saida_xml/        # Novos XMLs gerados
        ├── metadados/        # CSVs de extração
        ├── _retrieves/       # ZIPs e pastas de retrieve
        └── logs/
```

---

## ✅ Checklist Final

- [ ] Retrieve de produção realizado
- [ ] XMLs extraídos para `entrada_xml/`
- [ ] Divergências mapeadas
- [ ] Novos XMLs gerados
- [ ] Testes em sandbox realizados
- [ ] Deploy validado com pipeline ou VSCode

---

## ℹ️ Observações

- O script `10_extract_org_metadata.sh` só funcionará se os diretórios definidos no `.json` refletirem exatamente a estrutura física de pastas da máquina.
- A lista de customMetadata divergentes deve estar salva em `/entrada_xml`.
