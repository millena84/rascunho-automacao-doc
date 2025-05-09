# XXx_FieldsChnForm__mdt

**Label**: Fields Chn e Form  
**Descrição**: Define regras de exibição de campos de tela por canal e formato.  
**Gerado em**: 09/05/2025 04:21:35

## Campos

| Campo              | Label           | Tipo      | Obrigatório | Descrição                                   |
|-------------------|------------------|-----------|-------------|----------------------------------------------|
| XXx_Chn__c        | Chn              | Text      | Sim         | Identifica o canal (ex: MBL, SMS, PUSH)      |
| XXx_Form__c       | Form             | Text      | Não         | Identifica o formato da tela ou conteúdo     |
| XXx_FieldsTela__c | Fields da Tela   | TextArea  | Não         | Lista os campos exibidos                     |

## Registros

| Nome API       | Label        | XXx_Chn__c | XXx_Form__c | XXx_FieldsTela__c         |
|----------------|--------------|------------|-------------|----------------------------|
| MBL_WRN        | MBL - WRN    | MBL        | WRN         | campo_1;campo_2;campo_3    |
