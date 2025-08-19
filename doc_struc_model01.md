sugestão 01

---

# pastas:
1-overview  2-org  3-md  4-logs  5-outros  definicoes.txt
./1-overview:
architecture  governance  runbooks  sf_docs
./1-overview/architecture:
ADR-YYYYMMDD-title20chars.md  recommended_dev_patterns.md
./1-overview/governance:
./1-overview/runbooks:
feature_lifecycle  recurring_procedures
./1-overview/runbooks/feature_lifecycle:
./1-overview/runbooks/recurring_procedures:
creat_name_credencials.md  equal_org_certification.md  model.md
./1-overview/sf_docs:

./2-org:
_audit  _know_issues  _releases  classes  customapplication  flows  lwc  objects
./2-org/_audit:
./2-org/_know_issues:
./2-org/_releases:
model.md  YYYY.MM
./2-org/_releases/YYYY.MM:
./2-org/classes:
./2-org/customapplication:
./2-org/flows:
model.md
./2-org/lwc:
./2-org/objects:

./3-md:
./4-logs:
./5-outros:

---
<!-- arch overview -->

# Visão Geral da Arquitetura — Org Salesforce (IU Jornadas)

## Objetivo da Plataforma
Apoiar a orquestração de campanhas e comunicações (Push, SMS, E-mail) e gestão de briefings em squads internas.

## Escopo Funcional
- Sales/Service Core (usuários internos)
- Apps custom (JT, SG, CM, CHKL)
- Data Cloud (unificação de perfis e segmentos)
- Integrações: Mulesoft (ESB), Data Lake, Sistemas de disparo

## Papel no Ecossistema
Salesforce é o front de CRM e governança de campanhas; Data Cloud é a camada de identidade/segmentação; Mulesoft faz mediação sistêmica.

## Fluxo de Dados (alto nível)
Origem (DW/Datalake, Apps Mobile) → Mulesoft → Salesforce/Data Cloud → Personalization/Journey → Disparadores (Push/SMS) → Retornos (eventos) → DW.

## Qualidades Arquiteturais
- Segurança por padrão (OWD restritivo + Permission Sets)
- Observabilidade (event monitoring + logs custom)
- Escalabilidade (assíncrono, bulkificação, segmentação)
- Resiliência (retry com backoff; DLQ em integrações)

---
<!-- scope and limits -->

# Escopo e Limites

## Sob gestão do time Salesforce
- Modelagem e objetos: JT__c, SG__c, CM__c, CHKL__c
- Automação: Flows + Apex Services
- Data Cloud: Data Streams, Unificação, Segmentos
- Named Credentials e conectores Mulesoft

## Fora do escopo (outros times)
- Disparadores transacionais (Pega)
- Regras de tarifação SMS (fornecedor)
- Data Lake e ETL de origem (Time Dados)

## Acordos de Interface
- Requisições síncronas até 3s; acima disso, assíncrono
- Contratos versionados no API Manager (Mulesoft)

---

# ADR (Architecture Decision Record): [title | status]

## General Information
- **Date:** yyyy-mm-dd
- **Status:** Proposed | Approved | Obsolete

## ✍️ Details
### 📝 Context
  | Scenario | Restrictions | Requirements |
  |----------|--------------|--------------|
  |          |              |              |

---

### 📋 Options
#### 1: title
##### Description
- ex: what to use
- ex: what to access
- ex: what to integrate

##### Advantages
- point 1

##### Disadvantages
- point 1

#### 2: title
##### Description
##### Advantages
##### Disadvantages

---

### 🤝 Decision
Description, whats and  whys.

#### Decision makers
- name 1
- name 3

---

### 📓 Justification
List

---

### 🚨 Consequences
#### Positive
List

#### Negative
List

> or

#### Trade-offs

#### Operation impacts

#### Security impacts

#### Process impacts

#### Cost impacts

---

### 🛰️ Traceability
related itens

---

### 🔭 Future Actions

---

## 📖 History
| Date       | Author            | Description                      |  Release/Sprint |
|------------|------------------|----------------------------------------------|----------------|
| yyyy-mm-dd | Name  | Cesc                              | R3YYYY.S       |

---
<!-- c4 -->

# C4 — Nível 1 (Contexto)
Atores: Usuário Marketing, Squad CRM, App Mobile Cliente  
Sistemas: Salesforce Org (Core + Apps Custom), Data Cloud, Mulesoft, Data Lake, Disparadores (Push/SMS)

# C4 — Nível 2 (Contêineres)
- **Salesforce Core**: objetos padrão e permsets
- **Apps Custom**: JT/SG/CM/CHKL (Lightning)
- **Data Cloud**: identidade e segmentação
- **Mulesoft**: APIs e orquestração
- **Data Lake**: origem/consumo analítico
- **Disparadores**: provedores externos

# C4 — Nível 3 (Componentes — exemplo Apps Custom)
- LWC `jtChecklist` ↔ Apex `CHKLService`
- Flow `FLW_JT_CreateChecklist` (record-triggered)
- Custom Metadata `WW2_Config_*` (parâmetros de tela)

> Dica: mantenha os diagramas em `.drawio` + `.png`.

---
<!-- data flow - integration -->

# Fluxo de Dados — Campanha Push

1. **Perfis** (Data Lake) → Mulesoft → **Data Cloud** (Data Streams)
2. **Unificação** (Identity Resolution) → Segmentos (DQ + enriquecimento)
3. Segmento ativado → **Salesforce** (objetos JT/SG/CM) — grava briefings
4. **Personalization/Journey** consome segmentos e dispara
5. **Eventos de retorno** (entrega/clique) → Mulesoft → Data Lake e **Data Cloud** (conciliação)

## Metadados críticos
- Chave Correlação: `customerId` + `channel`
- Retenção: 90 dias para logs operacionais (Policy)
- 
---

<!-- infra diagrams -->

# Conexões e Segurança

## Acesso
- SSO via IdP corporativo (SAML)
- MFA obrigatório (Executivos e Operações)

## Integrações
- Named Credentials (OAuth 2.0 Client Credentials)
- Certificados rotacionados a cada 180 dias
- Lista de allowlists para endpoints Mulesoft

## Rede
- TLS 1.2+
- Política de CORS para LWC que chamam endpoints

## Observabilidade
- Event Monitoring + Log de Auditoria
- Correlation-Id propagado por Mulesoft

---

<!-- integration patterns -->

# Padrões de Integração

## Estilos
- **Síncrono** (<=3s): consultas leves (read-only)
- **Assíncrono**: criação em massa, callbacks, eventos

## Autenticação
- Named Credentials (OAuth2 CC/JWT)
- Rotação programada; sem segredos no código

## Confiabilidade
- Retry exponencial com jitter (3 tentativas)
- Circuit Breaker via Mulesoft/queue
- Idempotência: `External_Id__c` e `Correlation-Id`

## Contratos
- OpenAPI versionado; versionamento `v{n}` no path
- Erros mapeados (4xx funcionais, 5xx técnicos)

## Limites Salesforce
- Bulkificação (DML/Query)
- Callouts: governança de tempo e volume por transação

---

<!-- security patterns -->

# Padrões de Segurança

## Dados
- OWD restritivo; PS > Profiles; uso de Restriction Rules
- FLS/CRUD checado em Apex (Security.stripInaccessible)

## Credenciais
- Named Credentials (sem credencial hardcoded)
- Shield Encryption onde houver PII sensível

## Telas e APIs
- Validação server-side (Apex) e client-side (LWC)
- Escapar HTML; Content Security Policy

## Auditoria
- Field History em campos sensíveis
- Setup Audit Trail monitorado semanalmente

---

<!-- blueprint adaptado -->

# Salesforce Blueprint (Adaptado)

## Blocos Utilizados
- Platform Core (Sales/Service)
- Data Cloud (unificação/segmentos)
- Personalization/Journey (execução)
- Mulesoft (integrações)

## Blocos Planejados
- Agentforce (suporte/autoatendimento)
- Tableau (analítica de campanhas)

## Diretrizes
Separação de preocupações: Plataforma (governança) x Execução (canais) x Identidade (DC).

---

<!-- matriz RACI -->
# Matriz RACI — Arquitetura e Operações

| Atividade                          | CRM-Eng | Dados | Mulesoft | Segurança | Negócio |
|-----------------------------------|---------|-------|----------|----------|---------|
| Modelagem de objetos              | R       | C     | I        | C        | A       |
| Unificação de perfis (Data Cloud) | A       | R     | I        | C        | C       |
| Integrações outbound              | C       | I     | R        | C        | I       |
| Políticas de acesso/PSets         | R       | I     | I        | A        | C       |

---

<!-- dev patterns -->

# Recommended Patterns

## 🎲 Data Modeling

### Naming Standards

#### Objects

1. System-Related Acronym (ACM)
2. Business Domain (BDO)
    - AGNT – Agent
    - EXPE – Experience
    - JOUR – Journey (Marketing Cloud)
    - COMM – Client Communication
    - ... (add more as needed)
3. Purpose Information  (PurposeInformation - 21 char)
**Pattern:** ACM_BDOM_InformationName  
**Example:** CH7_COMM_

#### Fields (Limit: 40 characters)

1. System-Related Acronym (ACM)
2. Information Nature (see table below)
    - Number        : NUM
    - Code          : COD
    - Value         : VAL
    - Quantity      : QTY
    - Acronym       : ACY
    - Description   : DSC
    - Name          : NAM
    - Date/Time     : DTM
    - Percentage    : PCT
    - Text          : TXT
    - Image         : IMG
    - Day           : DAY
    - Month         : MON
    - Indicator     : IND
    - Year          : YER
    - Date          : DAT
3. Salesforce Data Type
    - Autonumber      : An
    - Formula         : Fm
    - Lookup          : Lk
    - Master-Detail   : Md
    - External Lookup : El
    - Checkbox        : Cb
    - Currency        : Cr
    - Date            : Dt
    - Date/Time       : Di
    - Email           : Em
    - Geolocation     : Gl
    - Number          : Nb
    - Percent         : Pc
    - Phone           : Ph
    - Picklist        : Pi
    - Multi-Picklist  : Mp
    - Text            : Tx
    - Text Area       : Ta
    - Long Text Area  : Lt
    - Rich Text       : Rt
    - Text Encrypted  : Te
    - Time            : Ti
    - URL             : Ur

**Pattern:** ACM_BDOM_InformationName

---

#### Relationship Strategy

- Always analyze business requirements before choosing a relationship type.
- Prefer Master-Detail for strict dependencies and roll-ups.
- Prefer Lookup for flexibility, orphan records, or optional relationships.
- Use a Junction Object for many-to-many relationships.
- Name relationship fields clearly and consistently.
- Consider impacts on security, automation, and reporting.
- Document all relationships for easier maintenance.
- Prefer External Lookup to relate Salesforce → external object (key on external). Uses the **External Id** field of the external object.
- Prefer Indirect Lookup to relate external object → Salesforce (key on Salesforce). Uses an **External Id** field on the Salesforce object.

**Types of Relationships:**

1. **Lookup Relationship**
   - More flexible (can be required or optional).
   - Allows associating records between objects without strong dependency.
   - *Example*: Account related to multiple Contacts.

2. **Master-Detail Relationship**
   - Strong dependency (child depends on parent).
   - Child record cannot exist without the master.
   - Sharing and access are inherited from the parent.
   - Enables Roll-Up Summary Fields.
   - *Example*: Opportunities related to an Account.

3. **Junction Object**
   - Used to create many-to-many relationships.
   - *Example*: A “Participation” object linking “Students” and “Courses”.

---

#### References:
- [Salesforce Object Relationships Explained | Lookup, Master-Detail, Junction, Self Relationship](https://www.youtube.com/watch?v=NMUeSl8xa0Y)
- [Many-to-Many Object Relationship](https://help.salesforce.com/s/articleView?id=platform.relationships_manytomany.htm&type=5)
- [Trailhead: Prepare for Your Salesforce Platform App Builder Credential](https://trailhead.salesforce.com/en/users/strailhead/trailmixes/prepare-for-your-salesforce-platform-app-builder-credential)
- [Superbadge: Object Relationships](https://trailhead.salesforce.com/content/learn/superbadges/superbadge-object-relationships-sbu)
- [Salesforce Help - Relationships Overview](https://help.salesforce.com/s/articleView?id=sf.relationships_overview.htm)
- [Developer Guide - Object Relationships](https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/relationships_among_objects.htm)
- [Schema Builder](https://help.salesforce.com/s/articleView?id=sf.schema_builder.htm)
- [Salesforce Object Reference](https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_concepts.htm)
- [Salesforce Developer Docs: External Objects & Relationships](https://developer.salesforce.com/docs/atlas.en-us.externalobjects.meta/externalobjects/external_object_relationships.htm)
- [Trailhead: Salesforce Connect – OData (External Objects)](https://trailhead.salesforce.com/content/learn/modules/lightning_connect/lightning_connect_intro)

---

## 🔏 Security Baseline

*(To be detailed)*

---

## ↔️ Flows

**Naming standards:**  
1. System-Related Acronym (ACM)  
2. Flow Type  
    - Screen: Sc  
    - Record-Triggered: Rc  
    - Scheduled: Sd  
    - Autolaunched: Au  

**Best Practices:**
- One responsibility per flow (encourage reuse).
- Always handle failures.
- Log important changes (system debug).

---

## 💻 Classes

- Minimum test coverage: 90%

### Triggers


---

### Apex Patterns

**Service Layer:**
- `<Object>Service`       : Orchestrates business rules and calls other classes.
- `<Object>Validator`     : Validates mandatory rules before persistence or execution.
- `<Object>Repository`    : Performs specific DML/SOQL operations.
- `<Object>TriggerHandler`: Manages triggers for objects.
- `<Object>Filter`        : Filters processed records.
- `<Object>Strategy`      : Applies variable logic according to the context.
- `<Object>Controller`    : Bridge between UI and Service Layer.
- `<Object>Factory`       : Used in integration contexts (create instances).
- `<Object>DTO`           : Used in data transport layers (APIs / complex LWCs).
- `<Object>Wrapper`       : For Aura / Visualforce components.
- `<Class>Test`           : Test classes.

**Recommendations:**
- Follow Service Layer Pattern.
- Always use `with sharing` and enforce FLS/CRUD.
- Check if the class requires the use of `Security.stripInaccessible`
- Avoid placing business logic in Controller classes; keep it in the Service class.
- Always use Named Credentials for callouts.
- Write unit tests covering all security scenarios (CRUD/FLS).
- Document any security considerations in the class header.
- When working with user data, always document which fields are being protected and tested for compliance with FLS/CRUD. This makes it easier for others to audit and maintain your code.
- ...

### Examples:
#### **`Security.stripInaccessible`**
##### Select without the protection:
```apex
List<Account> accounts = [SELECT Id, Name, AnnualRevenue FROM Account];
```
Even if the user does not have permission to view the AnnualRevenue field, the SOQL query will still return the field value.

##### Using `Security.stripInaccessible`
**Select example**
```apex
// Normal query
List<Account> accounts = [SELECT Id, Name, AnnualRevenue FROM Account];

// List with field-level security enforced
accounts = (List<Account>) Security.stripInaccessible(
    AccessType.READABLE,     // check access type
    accounts                 // query records
).getRecords();

```

**Insert/Update Example**
```apex
Account a = new Account(
    Name = 'Teste',
    AnnualRevenue = 5000000
);

// Remove fields that the user cannot create (enforces FLS on insert)
account = (Account) Security.stripInaccessible(
    AccessType.CREATABLE,
    new List<Account>{ account }
).getRecords()[0];

insert account;
```

**Extra**
Always validate CRUD permissions before performing DML:
```apex
if (Schema.sObjectType.Account.isCreateable()) {
    insert account;
} else {
    // Handle insufficient permissions
}
```

### References:
- [Component-Based Architecture (Trailhead)](https://trailhead.salesforce.com/content/learn/modules/lex_dev_lc_basics/lex_dev_lc_basics_intro)
- [Design Patterns for Salesforce Platform (Salesforce Architects)](https://architect.salesforce.com/design)

---

## 📱 UI (User Interface)

- Strongly typed props, documented events, Jest tests.
- Wrapper: Can be used in any UI solution.

### LWC

- `.html`
- `.js`
- `.xml`
- `.css`*
- `*cls` Wrapper
- `*cls` Controller
- `**html` App Wrapper

### Aura

- `.auradoc` (Documentation)
- `.cmp` (Component)
- `.js` Controller
- `.js` Helper
- `.js` Renderer
- `.css`*
- `*cls` Wrapper
- `*cls` Controller
- `**cmp` Component

### Visualforce

- `.page`
- `.cls` Controller
- `.component`
- `*cls` Wrapper
- `*cls` Controller
- `**page` Interface

### References:
- [LWC: Component Bundle Structure (Salesforce Docs)](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.create_components_structure)
- [LWC: Why Separate HTML, JS, and CSS? (Salesforce Blog)](https://developer.salesforce.com/blogs/2019/03/separating-html-css-and-javascript-in-lightning-web-components.html)
- [LWC Open Source - Architecture Overview](https://lwc.dev/guide/architecture)
- [Aura Components Developer Guide - Bundle Structure](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_bundle.htm)
- [Aura Components: When to Use Each File? (Trailhead)](https://trailhead.salesforce.com/content/learn/modules/lex_dev_lc_basics/lex_dev_lc_basics_files)
- [Visualforce Developer Guide - Controllers and Extensions](https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_controller.htm)
- [Visualforce Page Structure (Salesforce Docs)](https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_intro.htm)


---

## 🗹 Peer Review

*(To be detailed)*

---

## 📖 History

| Date       | Author | Description                   | Release/Sprint |
|------------|--------|------------------------------|----------------|
| yyyy-mm-dd | Name   | Initial version              | R3YYYY.S       |

---
<!--- governance policy -->
# Política de Governança Salesforce

## Objetivo
Garantir o uso seguro, padronizado e eficiente da plataforma Salesforce, alinhado às metas estratégicas e às políticas corporativas.

## Escopo
- Organizações Salesforce de Produção e Sandboxes.
- Ambientes de desenvolvimento e QA integrados ao Flosum.
- Aplicativos internos, integrações e Data Cloud.

## Princípios
1. **Segurança em primeiro lugar** — proteção de dados sensíveis.
2. **Inovação com responsabilidade** — adoção de novas funcionalidades com avaliação de risco.
3. **Colaboração** — decisões de arquitetura e mudanças discutidas em fóruns de governança.

## Autoridade
- **Change Advisory Board (CAB)**: aprova mudanças críticas.
- **Administradores Salesforce**: aplicam mudanças de configuração.
- **Desenvolvedores Salesforce**: implementam código seguindo padrões definidos.

---

<!-- security policy -->

# Política de Segurança Salesforce

## Autenticação
- MFA obrigatório para todos os usuários internos.
- SSO via IdP corporativo para usuários internos e Experience Cloud.

## Permissões
- OWD configurado com o princípio do menor privilégio.
- Perfis utilizados apenas para baseline; refinamentos via Permission Sets.

## Proteção de Dados
- Criptografia em repouso (Shield) para campos sensíveis.
- Máscaras e anonimização para dados de teste.

## Monitoramento
- Event Monitoring para auditoria de login e execução de APIs.
- Alertas automáticos para tentativas de login mal-sucedidas.

---

<!-- configuration policy -->

# Padrões de Configuração

## Segurança
- OWD como padrão "Private", exceto quando exigido por regra de negócio.
- Uso de Restriction Rules para cenários de filtragem avançada.

## Automação
- Proibir uso de Workflow Rules; usar Flows ou Apex.
- Process Builder em descontinuação — migrar para Flow.

## Integração
- Named Credentials para autenticação de APIs.
- Limite de 3 segundos para chamadas síncronas.

---
<!-- incident process --->
# Processo de Incidentes — Salesforce

## Classificação
- **P1**: indisponibilidade total do Salesforce.
- **P2**: falha em processo crítico (ex.: criação de campanha).
- **P3**: problemas pontuais sem impacto geral.

## Fluxo
1. Registro no ServiceNow/Jira com detalhes.
2. Triagem pelo N1 (Service Desk).
3. Escalonamento para N2 (Admins) ou N3 (Devs/Arquitetura).
4. Comunicação de status a cada 30 minutos (P1/P2).

## SLA
- P1: até 2h para mitigação.
- P2: até 8h para solução.

---
<!-- auditoria periodica -->
# Auditorias Periódicas

## Periodicidade
- Trimestral para revisão de acessos e perfis.
- Semestral para revisão de campos não utilizados.

## Checklist Trimestral
- Perfis sem login nos últimos 90 dias → desativar.
- Permission Sets sem uso → arquivar.
- Campos criados sem uso nos últimos 12 meses → avaliar exclusão.

## Checklist Semestral
- Revisão de Named Credentials expirando.
- Revisão de APIs integradas e limites consumidos.


---
<!-- metricas de governança -->
# Métricas de Governança

| Métrica | Objetivo | Meta |
|---------|----------|------|
| % de Deploys sem rollback | Qualidade de entregas | > 95% |
| Tempo médio de aprovação de mudança | Agilidade no CAB | <= 3 dias |
| % de Cobertura de Testes Apex | Conformidade | >= 85% |
| Nº de mudanças emergenciais | Estabilidade | < 5/mês |


---
<!-- basic runbook -->
# Runbook — `Function`
## Objective
Description

## Prerequisites
- 

---

## Steps
1. [action]
2. …

---

## Validation (pos-execution)
- [check1]
...

---

## Rollback
- [plan]
...

---

## Accountable
- Applicant / Executor / Approver

---

## Attachments
- Prints, links, other

---

## 📖 History

| Date       | Author | Description                   | Release/Sprint |
|------------|--------|------------------------------|----------------|
| yyyy-mm-dd | Name   | Initial version              | R3YYYY.S       |

---
<!-- runbook deploy flosum -->
...

---
<!-- gestao de permissoes -->
# Runbook — Gestão de Permissões

## Objetivo
Garantir que a concessão, alteração e remoção de acessos sigam boas práticas de segurança.

## Fluxo
1. Solicitação registrada no Jira/ServiceNow.
2. Aprovação do gestor do solicitante.
3. Análise de necessidade (perfil x permission set).
4. Aplicação da permissão no ambiente de QA.
5. Validação pelo solicitante.
6. Replicação para Produção via Flosum.

## Boas Práticas
- Princípio do menor privilégio.
- Evitar perfis com acesso administrativo completo.
- Usar Permission Sets para granularidade.

## Evidências
- Anexar aprovação formal e prints da configuração.

---
<!-- named credentials -->
# Runbook — Rotação de Certificados em Named Credentials

## Objetivo
Garantir a atualização de certificados e chaves sem interrupção de integrações.

## Procedimento
1. Gerar novo certificado no ambiente de QA.
2. Atualizar Named Credential no QA.
3. Validar integração.
4. Solicitar aprovação para Produção.
5. Atualizar Named Credential em Produção fora do horário crítico.
6. Monitorar logs e integrações por 30 min.

## Observações
- Certificados devem ser rotacionados com 15 dias de antecedência da expiração.
- Manter backup seguro do certificado anterior até confirmar sucesso da rotação.

---
<!-- auditoria periodica -->

# Runbook — Auditoria Trimestral Salesforce

## Objetivo
Revisar segurança e uso da plataforma trimestralmente.

## Itens
- Perfis inativos (>90 dias) → desativar.
- Permission Sets sem uso → excluir.
- Named Credentials expirando → renovar.
- Campos sem uso > 12 meses → avaliar exclusão.

## Procedimento
1. Executar relatório customizado.
2. Gerar lista de ações corretivas.
3. Aprovar plano com o comitê de governança.
4. Implementar mudanças via Flosum.


--- 

<!-- backup metadados? -->
# Runbook — Backup de Metadados Salesforce

## Objetivo
Garantir backup recorrente e versionado de metadados no GitHub.

## Procedimento
1. Executar `sf project retrieve start` no ambiente desejado.
2. Salvar saída na pasta local de backup.
3. Commit e push para branch `backup/YYYY-MM-DD`.
4. Revisar logs de execução.
5. Registrar no changelog.

## Frequência
- Semanal para produção.
- Antes de grandes releases.



---

<!-- release model -->

# Release yyyy.mm
**Date:** 2025-08-30  
**Time:** hh:00–hh:00 BRT  
**Brief:** [release objective]

## Itens
- [User story] (link)

---

## Impacts
### Technical
- Objects: 
- Flows: 
- Permissions: permset [nome]
- Classes:
...

---

### Business
- app
- screen
- ...?

---

## Risks and Mitigations
- [risk] → [mitigation]

---

## Rollback plan
- [steps]

---

## Test Evidence
- Link - `./YYYY.MM/…`

---

## 📖 History

| Date       | Author | Description                   | Release/Sprint |
|------------|--------|------------------------------|----------------|
| yyyy-mm-dd | Name   | Initial version              | R3YYYY.S       |

---

<!-- basic flow model -->

# Flow: `FLW_Rc_CreateRegisterX`

## Type
Record-Triggered (after insert/update)
Object: `X`

---

## Objective
- Create a register `X`
- Associate to `Y` when [conditions]

---

## Entrances/Exits
- Entrances: `$Record` (X)
- Exits: ID 

---

## Key steps
1. Decision [condition]
2. Create Records (X)
3. Update `$Record.X`

---

## Fault Handling
- Fault path → Log em `Log__c`, notificação para `Queue_xxx`

---

## Dependences
- Object: X, Y
- Permissions: `perm_FlowX`

---

## Limitations/Observability
- Volume: up to [X]/hour
- Metrics (SLI): success rate, average time

---

## Tests
- Scenarios, evidences and links

---

## 📖 History

| Date       | Author | Description                  | Release/Sprint |
|------------|--------|------------------------------|----------------|
| yyyy-mm-dd | Name   | Initial version              | R3YYYY.S       |

---

<!-- general class model -->

# Apex: ObjectPattern

## Patterns
- `<Object>Service`       
- `<Object>Validator`     
- `<Object>Repository`    
- `<Object>TriggerHandler`
- `<Object>Filter`        
- `<Object>Strategy`      
- `<Object>Controller`    
- `<Object>Factory`       
- `<Object>DTO`           
- `<Object>Wrapper`       
- `<Class>Test`           

## Responsability
[ONE responsability per class - Service Layer]

---

## Public signature
```apex
public with sharing class ObjectPattern {
  public static Id createForObject(Id objectRecordId, String field) { ... }
}
```

---

## More
- **Bulkable?** `yes`
- **Errors and exceptions:** [`condition 1`], ...
- **TestClass:** ClassnameTest
### Dependences:
- Name credentials: `yes|no|na`
- Other classes:

## Where it appears?
- ...

---

## 📖 History

| Date       | Author | Description                   | Release/Sprint |
|------------|--------|------------------------------|----------------|
| yyyy-mm-dd | Name   | Initial version              | R3YYYY.S       |

---

<!-- API model -->

---
<!-- triggerHandler model -->

---

<!-- toubleshooting log model -->

---

<!-- toubleshooting flow log model -->

---

<!-- toubleshooting log model -->

---

<!-- org summary model -->

# custom objects
| Label | apiName | Documentation |
|-------|-----|-----|
| Label    | ACM_DOM_ObjectName__c | [- ACM_DOM_ObjectName__c.md](../../md/objects/ACM_DOM_ObjectName__c.md) |
| Label    | ACM_DOM_ObjectName__c | [- ACM_DOM_ObjectName__c.md](../../md/objects/ACM_DOM_ObjectName__c.md) |

---

<!-- index model -->

# Salesforce organization doc

## Summary
- [Architecture](/1-overview/architecture/index.md)
- [Governance](/1-overview/governance/index.md)
- [Procedures (Runbooks)](/1-overview/runbooks/index.md)
- [Org overview](/2-org/index.md)
- [Releases](/2-org/releases/index.md)
- ???

<!--  **Nota:** Deploys são feitos via Flosum. Este site é apenas documentação. -->


fica faltando a parte de logs
