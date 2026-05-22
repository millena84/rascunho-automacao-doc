# Modelo de Documentação de Telas FlexPage/FlexPay para Salesforce

> Objetivo: servir como modelo-padrão para documentar telas do tipo FlexPage/FlexPay, suas regras associadas e os objetos/componentes envolvidos, de forma que uma transcrição textual de navegação possa ser usada por um agente como GitHub Copilot para preencher este documento com base no projeto Salesforce.

---

## 1. Metadados do documento

| Campo | Preenchimento |
|---|---|
| Nome funcional da tela | |
| Nome técnico da FlexPage | |
| Tipo da página | App Page / Record Page / Home Page / Outro |
| Canal | Lightning Experience / Experience Cloud / Service Console / Outro |
| Módulo / processo de negócio | |
| Jornada / etapa do processo | |
| Objetivo da tela | |
| Perfil(is) / permissão(ões) impactadas | |
| Aplicação / App Salesforce | |
| Workspace / Console / Navegação | |
| URL de referência (se aplicável) | |
| Ambiente analisado | Dev / QA / UAT / Prod |
| Versão do documento | |
| Responsável pelo preenchimento | |
| Data da documentação | |
| Fontes usadas | Transcrição / Metadata / Flow / Apex / Object Manager / Outro |

### 1.1 Escopo da documentação

Descrever, em linguagem objetiva, o que esta tela faz e qual parte do processo ela cobre.

**Exemplo:** esta FlexPage é usada na etapa de análise cadastral para o atendente revisar dados do cliente, complementar campos obrigatórios e acionar validações antes do envio para aprovação.

### 1.2 O que fica fora do escopo

Listar o que não deve ser documentado aqui para evitar mistura de assuntos.

**Exemplo:** regras de integração assíncrona, layout de objetos não exibidos na tela, batch jobs e regras globais sem impacto direto nesta navegação.

---

## 2. Resumo executivo da tela

### 2.1 Visão rápida

| Item | Descrição |
|---|---|
| O usuário acessa a tela para | |
| Principal ação executada | |
| Registro principal manipulado | |
| Registros relacionados manipulados | |
| Componentes mais relevantes | |
| Regras críticas | |
| Riscos operacionais | |

### 2.2 Narrativa funcional

Descrever a tela como se fosse uma "recepção de aeroporto": o usuário chega, passa por etapas, encontra bloqueios, confirma dados e só então segue viagem.

Estrutura sugerida:

1. Como o usuário entra na tela.
2. O que ele visualiza primeiro.
3. Quais dados precisa preencher ou revisar.
4. Quais condições alteram a exibição.
5. Quais ações salvam, validam, avançam, retornam ou bloqueiam.

---

## 3. Contexto de navegação

### 3.1 Origem da navegação

| Campo | Preenchimento |
|---|---|
| Tela anterior | |
| Ação que leva até esta tela | |
| Botão / link / quick action | |
| Condição prévia para acesso | |
| Registro precisa existir? | Sim / Não |
| Parâmetros recebidos na entrada | |

### 3.2 Destinos possíveis

| Ação do usuário | Destino | Condição |
|---|---|---|
| Salvar | | |
| Avançar | | |
| Voltar | | |
| Cancelar | | |
| Submeter | | |
| Outra ação | | |

### 3.3 Fluxo resumido

Descrever em 5 a 10 passos o caminho principal da navegação.

**Exemplo:**

1. Usuário abre o registro de proposta.
2. Clica em “Análise Financeira”.
3. A FlexPage carrega os componentes de dados do cliente.
4. Campos condicionais aparecem conforme o tipo de renda.
5. Ao salvar, regras obrigatórias e validações são executadas.
6. Se não houver erro, o processo avança para a próxima etapa.

---

## 4. Inventário de componentes da FlexPage

> Esta seção é o “mapa da tela”. Pense nela como a planta de uma casa: cada cômodo é um componente e cada componente tem uma função.

| Ordem | Região da tela | Componente visível | Tipo técnico do componente | API Name / Developer Name | Finalidade funcional | Origem dos dados | Editável? | Observações |
|---|---|---|---|---|---|---|---|---|
| 1 | | | | | | | Sim / Não | |
| 2 | | | | | | | Sim / Não | |
| 3 | | | | | | | Sim / Não | |

### 4.1 Componentes por região

#### Cabeçalho

| Componente | Descrição funcional | Ações disponíveis | Condições de exibição |
|---|---|---|---|
| | | | |

#### Coluna principal / painel central

| Componente | Descrição funcional | Campos exibidos | Condições de exibição |
|---|---|---|---|
| | | | |

#### Painel lateral / utilitários

| Componente | Descrição funcional | Campos ou ações | Condições de exibição |
|---|---|---|---|
| | | | |

#### Rodapé / ações finais

| Componente | Descrição funcional | Botões | Condições de habilitação |
|---|---|---|---|
| | | | |

---

## 5. Objetos e relacionamentos envolvidos

> Aqui a ideia é responder: “quais objetos a tela toca e em que parte da tela cada um aparece ou é preenchido?”.

| Objeto | API Name | Papel na tela | Tipo de uso | Componente(s) onde aparece | Campo-chave exibido | Campo-chave editado | Relação com objeto principal |
|---|---|---|---|---|---|---|---|
| | | | Principal / Relacionado / Apoio / Técnico | | | | |

### 5.1 Objeto principal

- Nome do objeto:
- API Name:
- Motivo de ser o objeto principal:
- Evento principal da tela sobre esse objeto: criação, edição, consulta, aprovação, complemento, revisão ou outro.

### 5.2 Objetos relacionados

| Objeto relacionado | Relação | Quando é lido | Quando é alterado | Em qual componente |
|---|---|---|---|---|
| | | | | |

### 5.3 Mapa campo x objeto x componente

| Campo de negócio | API Name do campo | Objeto | Componente da FlexPage | Ação do usuário | Persistência |
|---|---|---|---|---|---|
| | | | | Visualiza / Preenche / Altera / Confirma | Automática / Ao salvar / Ao avançar / Via automação |

---

## 6. Campos documentados

> Esta é uma das seções mais importantes. Ela permite transformar uma gravação de navegação em documentação objetiva.

| Ordem | Rótulo do campo na tela | API Name | Objeto | Tipo de campo | Componente onde aparece | Obrigatório? | Editável? | Valor padrão | Origem do valor | Regra de exibição | Regra de preenchimento | Observações |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | | | | Texto / Picklist / Número / Data / Checkbox / Lookup / Outro | | Sim / Não / Condicional | Sim / Não | | Usuário / Fórmula / Automação / Integração / Default | | | |

### 6.1 Campos obrigatórios por contexto

| Campo | Sempre obrigatório? | Condição quando obrigatório | Mensagem percebida pelo usuário |
|---|---|---|---|
| | Sim / Não | | |

### 6.2 Campos derivados ou autopreenchidos

| Campo destino | Origem | Regra de derivação | Momento da derivação | Usuário pode sobrescrever? |
|---|---|---|---|---|
| | | | Ao abrir / Ao alterar outro campo / Ao salvar | Sim / Não |

---

## 7. Regras de exibição de campo

> Pense nesta seção como um “semáforo”: em determinadas condições o campo aparece, desaparece, habilita ou bloqueia.

| ID da regra | Campo / componente afetado | Tipo de comportamento | Condição de disparo | Base técnica provável | Evidência observada na navegação | Impacto para o usuário |
|---|---|---|---|---|---|---|
| EXB-001 | | Exibir / Ocultar / Habilitar / Desabilitar / Tornar obrigatório | | Component Visibility / Conditional Rendering / Flow / LWC / Aura / Outro | | |

### 7.1 Regras detalhadas

#### Regra EXB-001

- Elemento afetado:
- Tipo de comportamento:
- Condição de entrada:
- Condição inversa:
- Campos envolvidos na condição:
- Objeto dos campos envolvidos:
- Componente onde a regra está configurada:
- Impacto funcional:
- Exemplo prático:
- Evidência na transcrição:
- Observação técnica para busca no repositório:

> Exemplo de observação técnica: verificar `component visibility`, expressões em LWC/Aura, parâmetros em Flow Screen, Dynamic Forms ou regras no controller.

---

## 8. Regras de validação

> Esta seção documenta os “bloqueios” do processo. Se a regra dispara, o usuário não consegue seguir ou salvar.

| ID da validação | Nome funcional | Objeto | Campo(s) envolvidos | Evento | Condição | Mensagem ao usuário | Tipo técnico provável | Severidade |
|---|---|---|---|---|---|---|---|---|
| VAL-001 | | | | Salvar / Avançar / Submeter / Alterar campo | | | Validation Rule / Flow / Apex / LWC / Outro | Bloqueante / Aviso |

### 8.1 Detalhamento da validação

#### Validação VAL-001

- Nome funcional:
- Nome técnico, se identificado:
- Objeto:
- Campos avaliados:
- Quando dispara:
- Regra em linguagem de negócio:
- Fórmula conhecida ou hipótese técnica:
- Mensagem exibida:
- Como o usuário corrige:
- Exemplo de cenário que dispara:
- Evidência na transcrição:
- Artefato provável no repositório Salesforce:

### 8.2 Catálogo de mensagens de erro

| Mensagem observada | Contexto | Possível origem técnica | Ação esperada do usuário |
|---|---|---|---|
| | | | |

---

## 9. Regras de negócio de preenchimento

> Aqui entram as regras do tipo “se o usuário preencher X, então Y deve acontecer”. É a lógica do formulário em ação.

| ID da regra | Gatilho | Campo(s) de entrada | Campo(s) afetados | Comportamento esperado | Momento | Persistência |
|---|---|---|---|---|---|---|
| NEG-001 | Usuário informa valor / altera opção / clica ação | | | | Imediato / Ao sair do campo / Ao salvar / Ao avançar | Temporária / Persistida |

### 9.1 Detalhamento da regra de negócio

#### Regra NEG-001

- Nome funcional:
- Objetivo da regra:
- Evento gatilho:
- Campo ou ação de entrada:
- Resultado esperado na tela:
- Campo(s) ou componente(s) alterado(s):
- Objeto(s) impactado(s):
- Dependências:
- Exceções:
- Exemplo prático de uso:
- Evidência na transcrição:
- Onde procurar no projeto Salesforce:

### 9.2 Encadeamentos entre regras

| Regra origem | Regra dependente | Relação entre elas | Risco de impacto |
|---|---|---|---|
| | | | |

---

## 10. Ações da tela

| Ação visível ao usuário | Tipo | Componente / botão | Condição para aparecer | Condição para habilitar | Efeito funcional | Destino / consequência |
|---|---|---|---|---|---|---|
| | Salvar / Avançar / Voltar / Cancelar / Enviar / Custom Action | | | | | |

### 10.1 Ações automáticas

| Ação automática | Quando ocorre | O que altera | Evidência percebida |
|---|---|---|---|
| | | | |

---

## 11. Automação e lógica técnica associada

> Esta seção ajuda o Copilot a cruzar a documentação funcional com o repositório técnico.

| Tipo de artefato | Nome provável | Papel na tela | Relação com regra documentada | Confiança da hipótese |
|---|---|---|---|---|
| FlexPage | | Estrutura da tela | | Alta / Média / Baixa |
| Lightning Record Page / Dynamic Forms | | | | |
| Flow | | | | |
| Apex Class | | | | |
| Trigger | | | | |
| Validation Rule | | | | |
| Custom Metadata / Custom Setting | | | | |
| LWC / Aura | | | | |

### 11.1 Pontos de busca no projeto

- Pasta/metadata esperada para a FlexPage:
- Componentes customizados envolvidos:
- Flows potencialmente relacionados:
- Objetos e fields para inspecionar:
- Validation Rules a verificar:
- Classes Apex a verificar:
- Metadata parametrizada a verificar:

---

## 12. Parâmetros e regras configuráveis

> Esta seção é útil quando a tela possui comportamento parametrizado, como visibilidade, obrigatoriedade, textos ou limites definidos fora do componente.

| Parâmetro | Onde está configurado | Valor atual | Impacto funcional | Quem mantém |
|---|---|---|---|---|
| | Custom Metadata / Custom Setting / Label / Flow Input / LWC Property / Outro | | | |

### 12.1 Dependências de parametrização

| Regra funcional | Parâmetro dependente | Risco se alterar | Evidência |
|---|---|---|---|
| | | | |

---

## 13. Sequência de navegação observada

> Esta seção foi desenhada para ser preenchida a partir de uma transcrição textual. Ela funciona como uma “linha do tempo” da gravação.

| Passo | Ação do usuário | Elemento acionado | Campos envolvidos | Resposta da tela | Regra inferida | Objeto(s) impactado(s) |
|---|---|---|---|---|---|---|
| 1 | | | | | | |
| 2 | | | | | | |
| 3 | | | | | | |

### 13.1 Trechos relevantes da transcrição

| Trecho da transcrição | Interpretação funcional | Seção do documento que deve ser alimentada |
|---|---|---|
| | | Campos / Regras de exibição / Validações / Regras de negócio / Ações |

---

## 14. Matriz de rastreabilidade

> Esta é a ponte entre o que o usuário faz, o que a tela mostra e onde isso provavelmente existe no repositório.

| ID funcional | Tipo | Descrição resumida | Evidência na navegação | Objeto/campo | Componente | Artefato técnico provável |
|---|---|---|---|---|---|---|
| EXB-001 | Exibição | | | | | |
| VAL-001 | Validação | | | | | |
| NEG-001 | Negócio | | | | | |

---

## 15. Riscos, dúvidas e lacunas

| Item | Tipo | Descrição | Impacto | Próxima ação sugerida |
|---|---|---|---|---|
| 1 | Dúvida / Lacuna / Risco / Hipótese | | | |

---

## 16. Critérios de qualidade do preenchimento

Use este checklist ao completar a documentação:

- [ ] Toda regra observada na transcrição foi registrada.
- [ ] Cada campo possui objeto e componente associados.
- [ ] Regras de exibição estão separadas de validações.
- [ ] Regras de negócio de preenchimento estão descritas em linguagem funcional.
- [ ] Há distinção entre evidência observada e hipótese técnica.
- [ ] Objetos principais e relacionados foram identificados.
- [ ] Ações visíveis e automáticas foram documentadas.
- [ ] Dependências de parametrização foram registradas.
- [ ] A matriz de rastreabilidade permite buscar os artefatos no projeto.

---

## 17. Instruções para preenchimento por IA

> Esta seção não documenta a tela em si; ela orienta um agente a preencher o documento de forma consistente.

### 17.1 Regras de preenchimento

1. Preencher apenas com base em evidências da transcrição e do repositório.
2. Quando houver inferência, marcar claramente como hipótese.
3. Não misturar regra de exibição com validação.
4. Não misturar comportamento de campo com comportamento de botão.
5. Sempre associar campos a objeto e componente.
6. Sempre registrar o passo da navegação em que a regra foi percebida.
7. Quando uma regra não for confirmada tecnicamente, usar “tipo técnico provável”.

### 17.2 Convenções recomendadas

- Prefixos de IDs:
  - `EXB-` para regras de exibição.
  - `VAL-` para validações.
  - `NEG-` para regras de negócio.
  - `ACO-` para ações, se desejar expandir.
- Usar linguagem funcional para o negócio e linguagem técnica apenas nos campos apropriados.
- Registrar mensagens exatamente como vistas pelo usuário, quando disponíveis.
- Em caso de dúvida sobre objeto, buscar vínculo pelo campo/API Name antes de preencher.

### 17.3 Escala de confiança

| Nível | Significado |
|---|---|
| Alta | Evidência direta na transcrição e confirmação no metadata/código |
| Média | Evidência clara na transcrição, mas sem confirmação técnica completa |
| Baixa | Inferência plausível com pouca evidência direta |

---

## 18. Prompt-base sugerido para uso futuro com Copilot

> Abaixo, um texto-base que pode ser adaptado quando chegar a hora de automatizar o preenchimento.

```text
Use a transcrição de navegação fornecida e este modelo Markdown para preencher integralmente a documentação funcional e técnica da tela Salesforce. Considere o contexto da FlexPage/FlexPay, identifique campos, componentes, objetos, regras de exibição, validações, regras de negócio de preenchimento, ações da tela, automações relacionadas e evidências observadas. Cruze a transcrição com os arquivos do projeto Salesforce disponíveis no repositório. Quando houver certeza, preencha objetivamente. Quando houver inferência, marque como hipótese e indique a confiança. Sempre associe cada campo ao objeto e ao componente em que aparece. Sempre associe cada regra ao passo da navegação em que foi percebida.
