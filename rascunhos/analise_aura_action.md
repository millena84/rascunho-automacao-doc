Aqui está um exemplo funcional de método `@AuraEnabled` em Apex, baseado na documentação oficial da Salesforce para integração com Agentforce (recurso beta do Winter '26). Esse método pode ser exposto como uma agent action em projetos Agentforce, permitindo que o agente crie contas automaticamente via instruções como "Create an Account named MegaCorp".[1]

## Exemplo de Classe Apex
A classe `AccountController` inclui métodos anotados com `@AuraEnabled`, como `createAccount`, que recebe parâmetros tipados e insere uma nova conta. Ela é projetada para ser gerada em OpenAPI e registrada no API Catalog para uso em Agentforce.[2][1]

```apex
public with sharing class AccountController {
    @AuraEnabled
    public static Id createAccount(String accountName) {
        Account newAccount = new Account(Name = accountName);
        insert newAccount;
        return newAccount.Id;
    }
}
```

## Como Expor como Agent Action
1. Gere o documento OpenAPI via VS Code (comando "SFDX: Create OpenAPI Document from This Class (Beta)") após instalar a extensão Agentforce for Developers.[1]
2. Implante o `.yaml` e `.externalServiceRegistration-meta.xml` no org para registrar no API Catalog sob "AuraEnabled (Beta)".[1]
3. Em Setup > Agentforce Asset > New Agent Action, selecione "Apex" > "AuraEnabled Method (Beta)" e escolha o método. Adicione a uma topic no Agent Builder.[1]

## Projetos e Documentação Relacionados
- **Blog Oficial**: Detalha o fluxo completo para Agentforce, incluindo teste do agente.[1]
- **Docs Salesforce**: Guia para criar actions de Apex controllers em Agentforce.[3][1]
- Exemplos em repositórios GitHub ou Trailhead usam padrões semelhantes para Aura/LWC, adaptáveis a Agentforce.[4][2]

[1](https://developer.salesforce.com/blogs/2025/09/auraenabled-apex-methods-are-now-available-as-agent-actions)
[2](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/apex_records.htm)
[3](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-auraenabled.html)
[4](https://github.com/forcedotcom/AuraEnabledScanner)
[5](https://developer.salesforce.com/docs/platform/lwc/guide/apex-continuations-auraenabled.html)
[6](https://www.youtube.com/watch?v=6nX8jeGhf2c)
[7](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/controllers_server_apex_auraenabled_annotation.htm)
[8](https://www.apexhours.com/introduction-to-aura/)
[9](https://www.linkedin.com/posts/salesforcedevs_auraenabled-apex-methods-are-now-available-activity-7371229692177166336-E7vO)
[10](https://www.seismic.com/newsroom/press-releases/salesforce-agentforce-aura/)
[11](https://www.youtube.com/watch?v=SRa3PlF44tc)
[12](https://help.salesforce.com/s/articleView?id=release-notes.rn_lwc_aura_ai_descriptions.htm&release=260&type=5)
[13](https://developer.salesforce.com/docs/einstein/genai/guide/agent-auraenabled-prerequisites.html)
[14](https://developer.salesforce.com/docs/component-library/bundle/aura:handler/documentation)
[15](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_AuraEnabled.htm)
[16](https://developer.salesforce.com/docs/platform/code-builder/guide/codebuilder-aura.html)
[17](https://www.youtube.com/watch?v=zn1Vm28pmgQ)
[18](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/ref_attr_types_apex.htm)
[19](https://gist.github.com/msrivastav13/7b802b44f51b4a4d8d7235fd0ec3902d)
[20](https://www.apexhours.com/call-apex-method-from-lightning-web-components/)
[21](https://trailhead.salesforce.com/content/learn/modules/lightning-web-components-and-salesforce-data/use-apex-to-work-with-data)
[22](https://appomni.com/ao-labs/lightning-components-a-treatise-on-apex-security-from-an-external-perspective/)
[23](https://www.apexhours.com/serializing-and-deserializing-data-in-lwc-and-apex/)
[24](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/controllers_server_apex_returning_data.htm)

---

considere os exemplos do link: https://developer.salesforce.com/blogs/2025/09/auraenabled-apex-methods-are-now-available-as-agent-actions?utm_source=perplexity.
agora considere uma classe simples que recebe uma var com id1;id2;id3 e deve fazer um split, transformar numa lista e para cada registro, trazer dados de um objeto CM. a classe tem um wrapper. 
pensando nisso e numa consulta simples, Emile como seria o documento openapi completo. 
esssa classe vai virar action de um agente employee agent do agentforce

Um documento OpenAPI completo para essa classe segue o mesmo padrão do exemplo do `AccountController`, mudando apenas o schema de entrada/saída e o path/operationId.  Abaixo está um modelo em YAML para um método que recebe `"id1;id2;id3"` e retorna uma lista de wrappers de registros de CM, já preparado para virar action de um **employee agent** no Agentforce.[1]

## Exemplo de classe Apex (referência)

```apex
public with sharing class CMController {
    public class CMWrapper {
        @AuraEnabled public Id   cmId;
        @AuraEnabled public String name;
        @AuraEnabled public String status;
        @AuraEnabled public String ownerName;
    }

    @AuraEnabled
    public static List<CMWrapper> getCMRecords(String recordIdsSemicolon) {
        List<Id> ids = new List<Id>();
        for (String sId : recordIdsSemicolon.split(';')) {
            if (String.isNotBlank(sId)) {
                ids.add((Id)sId);
            }
        }

        List<CMWrapper> result = new List<CMWrapper>();
        for (CM__c cm : [
            SELECT Id, Name, Status__c, Owner.Name
            FROM CM__c
            WHERE Id IN :ids
        ]) {
            CMWrapper w = new CMWrapper();
            w.cmId      = cm.Id;
            w.name      = cm.Name;
            w.status    = cm.Status__c;
            w.ownerName = cm.Owner.Name;
            result.add(w);
        }
        return result;
    }
}
```

## OpenAPI completo (com extensões Agentforce)

```yaml
openapi: 3.0.3
info:
  title: CMController AuraEnabled Methods
  version: '1.0.0'
  description: >
    AuraEnabled Apex methods for retrieving CM records by a semicolon-separated
    list of record Ids, exposed as agent actions for an Employee Agent in Agentforce.
  x-sfdc:
    publishAsAgentAction: true
    topics:
      - name: Employee CM Management
        description: Actions that help employees retrieve CM records for analysis and support.
        actions:
          - operationId: getCMRecords

servers:
  - url: https://yourInstance.my.salesforce.com/services/data/v{version}/auraenabled/CMController
    description: AuraEnabled endpoint for CMController

paths:
  /getCMRecords:
    post:
      operationId: getCMRecords
      summary: Get CM records by semicolon-separated Ids
      description: >
        Given a semicolon-separated string of CM record Ids (for example
        "a01xx000000001A;a01xx000000001B"), returns a list of CM records
        with key details for each record.
      tags:
        - CM
      x-sfdc:
        apexClass: CMController
        apexMethod: getCMRecords
        auraEnabled: true
        publishAsAgentAction: true
        # Opcional: restringir ao tipo de agente
        agentAction:
          label: Get CM Records
          description: Retrieve CM records by a list of Ids for employee workflows.
          category: Employee
      requestBody:
        required: true
        description: Semicolon-separated list of CM record Ids.
        content:
          application/json:
            schema:
              type: object
              properties:
                recordIdsSemicolon:
                  type: string
                  description: >
                    Semicolon-separated list of CM record Ids
                    (for example "a01xx000000001A;a01xx000000001B").
              required:
                - recordIdsSemicolon
      responses:
        '200':
          description: List of CMWrapper with data for each CM record.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/CMWrapper'
        '400':
          description: Invalid request (for example, malformed Ids).
        '500':
          description: Server error while retrieving CM records.

components:
  schemas:
    CMWrapper:
      type: object
      description: Wrapper returned by the AuraEnabled method for CM records.
      properties:
        cmId:
          type: string
          description: CM record Id.
        name:
          type: string
          description: CM name.
        status:
          type: string
          description: CM status.
        ownerName:
          type: string
          description: Owner name of the CM record.
```

Esse modelo segue a estrutura mostrada no blog da Salesforce (paths com `post`, `operationId`, `components/schemas` e uso de `x-sfdc.publishAsAgentAction` e `topics`) e é adequado para gerar uma agent action consumível por um **employee agent** no Agentforce.[1]

[1](https://developer.salesforce.com/blogs/2025/09/auraenabled-apex-methods-are-now-available-as-agent-actions)

---

seria possível subir esse pacote vis deploy dx sem criar o documento pela extensao do vscode?

Sim, é possível fazer deploy manual do pacote via Salesforce DX sem usar a extensão do VS Code para gerar o OpenAPI.  Você cria os arquivos YAML e XML manualmente (baseados no exemplo acima) e os coloca na pasta `force-app/main/default/externalServiceRegistrations/CMController`, depois deploya com `sf project deploy start`. 

## Passos para Deploy Manual

Crie a estrutura de pastas no seu projeto SFDX:

```
force-app/
└── main/
    └── default/
        └── externalServiceRegistrations/
            └── CMController/
                ├── CMController.externalServiceRegistration-meta.xml
                └── CMController.yaml
```

- **CMController.externalServiceRegistration-meta.xml** (mínimo obrigatório):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<ExternalServiceRegistration xmlns="http://soap.sforce.com/2006/04/metadata">
    <masterLabel>CMController AuraEnabled</masterLabel>
    <description>CM records retrieval for Employee Agent</description>
    <openapiSpecSource>CMController.yaml</openapiSpecSource>
    <schemaType>GeneratedApi</schemaType>
    <namedCredential>Callout_CMController</namedCredential>
    <!-- Opcional: named credential para autenticação -->
</ExternalServiceRegistration>
```

- **CMController.yaml**: Cole o OpenAPI completo do exemplo anterior.

## Comandos DX para Deploy

```
# Autorize o org (se não estiver)
sf org login web --alias production

# Deploy apenas os External Services
sf project deploy start --source-dir force-app/main/default/externalServiceRegistrations --target-org production

# Verifique no Setup > API Catalog > AuraEnabled (Beta)
```

Essa abordagem replica exatamente o que a extensão faz, permitindo versionamento no Git e deploy CI/CD.  Após deploy, crie a agent action em Setup > Agentforce Asset > New Agent Action > Apex > AuraEnabled Method (Beta).
