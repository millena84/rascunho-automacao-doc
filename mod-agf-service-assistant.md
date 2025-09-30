# módulo **Get Ready for Service Assistant** do Trailhead para Salesforce Agentforce Service Assistant:[1]

***

**Objetivo do Módulo**

O módulo prepara você para implantar o Service Assistant, um agente de IA assistiva no Service Cloud, ajudando equipes de atendimento a resolver casos de clientes de maneira mais rápida e eficiente.

***

### O que você aprende aqui?

- **Descrever o que é o Agentforce Service Assistant**  
  É um agente de IA assistiva (não conversacional e não autônomo) que aparece na página de registro de caso do Salesforce, oferecendo resumos rápidos do caso e orientações passo a passo para resolução (chamadas de "service plan").

- **Entender os fundamentos do planejamento para usar o Service Assistant**  
  Antes de configurar, você deve:  
  - Identificar quais tipos de casos o assistente ajudará a resolver (por exemplo, documentação de viagem, seguro viagem etc.).
  - Garantir que o assistente esteja conectado aos dados relevantes da empresa no Salesforce.

- **Explicar o que são fontes de grounding do Service Assistant**  
  O grounding é essencial! O Service Assistant baseia seus planos de atendimento em:  
  - Políticas e instruções da empresa traduzidas em tópicos Agentforce.
  - Dados de casos do Salesforce (Service AI Grounding).
  - Artigos de conhecimento, integrados via Agentforce Data Libraries.

- O assistente, integrado aos dados, elimina consultas manuais demoradas, trazendo respostas e orientações diretamente para quem está atendendo.

***

### Como funciona na prática? (Exemplo Coral Cloud Resorts)

Imagine uma empresa que recebe muitos casos sobre documentação de viagem e seguro. O gerente identifica que esses casos são demorados e sensíveis.  
Com o Service Assistant, os atendentes recebem orientações detalhadas, passo a passo, baseadas nas políticas da empresa e nos dados dos casos, acelerando a resolução.

***

### Como preparar?

1. **Definir os casos foco (Use Cases)**  
   Decidir em quais cenários o Service Assistant irá atuar—casos que exigem atenção especial ou envolvem múltiplos sistemas.

2. **Preparar e conectar os dados (Grounding Sources)**  
   - Criar tópicos Agentforce que agrupam instruções detalhadas para cada tipo de caso.
   - Garantir que políticas, fluxos e artigos estejam disponíveis para acesso pelo assistente.

3. **Configurar critério de elegibilidade (Service Plan Eligibility Criteria)**  
   - Controla quando o plano de serviço é criado (por exemplo, apenas casos de alta prioridade, de uma fila específica ou vindos de determinado canal).
   - Pode usar um template de flow disponibilizado pela Salesforce ou personalizar (autolaunched flow).

***

### Dicas rápidas didáticas

- **Tópicos** categorizam grupos de instruções para cada tipo de caso.
- **Instruções** devem seguir as políticas da empresa e ser claras, condicionais e sequenciais.
- **Data Library** enriquece planos usando artigos do Knowledge, via RAG (Recuperação com Geração Aumentada).

***

Resumindo:  
Esse módulo te ensina a planejar e preparar todos os detalhes para garantir que, ao configurar o Service Assistant, ele realmente otimize a rotina do atendimento, trazendo orientação precisa, baseada nos dados e normas da empresa.

Se quiser ajuda prática de como criar tópicos, instruções ou configurar eligibility, posso trazer tutoriais ou exemplos!

---

[1](https://trailhead.salesforce.com/pt-BR/content/learn/modules/agentforce-service-assistant/plan-for-service-assistant?trail_id=agentforce-service-assistant-onboarding-setup-and-customization)

---

# módulo **Set Up Service Assistant** e um passo a passo detalhado para fazer o exercício de validação![1]

***

## Objetivo do módulo

Você aprende a configurar o Service Assistant no Salesforce, criando o agente, tópicos com instruções e configurando critérios de elegibilidade para que o assistente comece a atuar em casos específicos do seu atendimento.

***

## Passo a passo didático de configuração

### 1. **Crie um Playground com Data Cloud**
- Clique em **Create Playground** no topo da página do Trailhead.
- Conecte esse playground ao Trailhead (se não fez isso antes).

### 2. **Habilite as funções do Agentforce**
- **Onde configurar:**
  - **Setup** (Configurações) no Salesforce.
  - Menu rápido: pesquise por **Service Assistant**.
  - Ative o Einstein Generative AI (`Go to Einstein Setup`, depois "Turn On Einstein").
  - Pesquise e selecione **Agentforce Agents**.
  - Ative **Agentforce** e o **Agentforce (Default) Agent**.

### 3. **Crie seu agente Service Assistant**
- Na página Agentforce Agents Setup, clique em **+ New Agent**.
- Escolha **Agentforce Service Assistant** e clique em **Next**.
- Preencha o campo da empresa (Company) com as informações do exemplo.
- Marque a opção para registrar eventos (Keep a record of conversations with Enhanced Event Logs).
- Clique em **Create**.

### 4. **Crie tópicos e instruções**
- No Agentforce Builder (aparece logo após criar o agente), clique em **New Topic**.
- Preencha os dados do tópico, por exemplo:  
  - Nome: Travel Documentation
  - API Name: Travel_Documentation
  - Adicione a descrição conforme os requisitos (“Ajuda para documentação de viagem…”).
- Insira instruções claras, separadas (exemplo: conferir documentos, dar dicas, informar prazos etc.).
- Clique em **Next** e depois **Finish**.
- Por fim, clique em **Activate** (Ativar).

### 5. **Ative o Service AI Grounding**
- De volta a **Setup**, procure **Service Assistant**.
- Vá para a seção **Service AI Grounding for Cases** e clique em **Go to Service AI Grounding**.
- Ative a função.
- Em **Choose Objects and Fields for Grounding**, selecione o objeto **Case**.
- Em **Case Fields**, edite para definir **Subject** e **Description**.
- Salve e ative.

### 6. **Configure critérios de elegibilidade**
- Na seção **Define Service Plan Eligibility Criteria**, clique em **Go to Flows**.
- Procure o flow **Check Service Plan Eligibility**.
- No Flow Builder, configure os critérios, exemplo:
  - **Priority = High**
  - **Case Origin = Email**
- Salve com o nome do caso, ex.: Travel Documentation, e ative o flow.
- Volte à configuração do Service Assistant e selecione esse flow nas opções de elegibilidade.

### 7. **Ative o Service Assistant**
- Deslize o toggle para **On** na seção **Turn On Service Assistant**.

### 8. **Adicione o componente à página de caso**
- No Salesforce, abra o **Apps Launcher** e selecione **Service**.
- Entre na aba **Cases**.
- Abra um caso (ex.: Help with Travel Documentation).
- Clique no ícone de engrenagem (Lightning Gear) e escolha **Edit Page**.
- Na tela de componentes, arraste **Service Assistant** para o layout.
- Delete componentes que não são necessários (ex.: Milestones/Related).
- Clique **Save** e **Activate**.
- Escolha como quer ativar: **Org Default** ou **App Default** (**Service Console** para desktop).

***

## **Exercício de validação do Trailhead**

- Leia as instruções “Prepare-se” e siga no seu Agentforce Playground.
- Após configurar tudo, volte ao módulo e clique em **Check Challenge** no final da página para validar (e ganhar 500 pontos!).

***

### **Referências de configuração no menu Salesforce**

- **Inglês:**  
  - Setup  
  - Service Assistant  
  - Agentforce Agents  
  - Service AI Grounding  
  - Flows (Flow Builder)  
  - Lightning App Builder (Edit Page)

- **Português:**  
  - Configurações  
  - Assistente de Serviço  
  - Agentes Agentforce  
  - Baseamento AI de Serviço  
  - Fluxos (Construtor de Fluxo)  
  - Construtor Lightning de Aplicativos (Editar Página)

***

Se precisar de orientação para um campo ou tela específica, basta pedir a etapa!
---

[1](https://trailhead.salesforce.com/pt-BR/content/learn/modules/agentforce-service-assistant/set-up-service-assistant?trail_id=agentforce-service-assistant-onboarding-setup-and-customization) 

---

# módulo **Test Service Assistant** do Trailhead para Salesforce Agentforce Service Assistant:[1]

***

**Objetivo do módulo**

Ensinar como testar e experimentar o Service Assistant já configurado, garantindo que as orientações e planos de atendimento funcionem conforme esperado para ajudar agentes a resolver casos de clientes com eficiência.

***

### O que você aprende neste módulo?

- **Como criar um plano de serviço (service plan) para um caso**
- **Como visualizar e ajustar o comportamento do assistente no registro de casos**
- **Como avaliar se as instruções e tópicos criados realmente ajudam o atendimento**

***

### Passo a Passo Prático

1. **Acesse o Service Console**  
   Use o App Launcher do Salesforce para abrir o console de atendimento.

2. **Selecione um caso para teste**  
   No módulo, o exemplo é o caso “Help with Travel Documentation”. Você pode selecionar qualquer caso real ou de teste do seu ambiente.

3. **Edite os detalhes do caso**  
   Faça pequenas alterações no assunto ou na descrição (por exemplo, adicione pontos ou informações extras) e salve.

   - **O que acontece?**  
     O Service Assistant entra em ação e gera um resumo do caso, além de etapas resumidas para resolução.

4. **Crie um plano de serviço detalhado**
   No componente do Service Assistant exibido na página do caso, clique em **Draft Plan**. Aguarde até 2 minutos; o sistema irá criar um plano sequencial, com checkboxes para acompanhamento.

   - Marque as etapas conforme forem realizadas; o progresso é salvo automaticamente.

5. **Redraft Plan (Refazer o Plano)**
   Caso precise alterar instruções, temas ou detalhes do caso, pode clicar em **Redraft Plan** (apenas se nenhuma etapa estiver marcada como concluída) para gerar um novo plano com as informações atualizadas.

***

### Dicas rápidas

- O teste é feito direto na tela do registro do caso, e não nas áreas comuns de teste de agentes do Agentforce.
- Use seu ambiente de playground para experimentar com diferentes tipos de casos, instruções e critérios de elegibilidade.
- Teste múltiplos cenários, avaliando se o assistente realmente sugere soluções úteis e específicas para sua empresa.

***

### Resumo Final

O **Service Assistant** automatiza tarefas, fornece resumos de casos e gera orientações detalhadas baseadas nos dados únicos da sua empresa, elevando a eficiência dos agentes e a experiência do cliente.  
Testar o assistente é essencial para garantir que os planos sejam claros, práticos e realmente ajudem no atendimento.  
Se algo não sair como esperado nos testes, basta ajustar tópicos/instruções e testar de novo: a personalização faz toda diferença!

---

[1](https://trailhead.salesforce.com/pt-BR/content/learn/modules/agentforce-service-assistant/test-service-assistant?trail_id=agentforce-service-assistant-onboarding-setup-and-customization)
