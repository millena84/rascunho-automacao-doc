A estrutura de acessos numa organização Salesforce Platform é fundamental para garantir segurança, privacidade e o funcionamento fluido dos processos do negócio. Esses mecanismos permitem decidir quem pode ver, editar, criar ou excluir dados e funcionalidades.

Abaixo segue uma explicação didática – com exemplos, analogias e recomendações práticas – dos principais componentes: OWD, Roles, Profiles, Permission Sets e Permission Set Groups, além dos links oficiais de documentação.

***

### Organization-Wide Defaults (OWD)

**O que são:**  
OWD define o nível base de acesso aos registros de cada objeto. Funciona como "o muro" do condomínio: é o bloqueio padrão que impede que os habitantes vejam o que acontece nos apartamentos uns dos outros, a não ser que se tenha uma permissão especial.[1][2][3]

**Quando usar:**  
Sempre defina primeiro, antes de criar regras, papéis ou permissões extras. Mantenha o acesso tão restritivo quanto o negócio permitir (por exemplo, OWD Private para dados sensíveis).[2][1]

**Exemplo prático:**  
Se Clients.Oportunidades estiverem em OWD Private, apenas o dono (e seus hierarquicamente superiores) podem ver, exceto se houver regras de compartilhamento ou permissões específicas.

**Boas práticas:**  
- Sempre prefira OWD mais restritivo
- Só relaxe se houver real necessidade de colaboração
- Revise periodicamente as definições de OWD

**Documentação:**  
- [OWD Salesforce Documentation (oficial)](https://help.salesforce.com/s/articleView?id=platform.security_sharing_owd_about.htm&language=en_US&type=5)
- [Guia prático de OWD](https://techimplement.com/tech-center/a-practical-approach-to-owd-in-salesforce/)[2]

***

### Roles (Hierarquia de Papéis)

**O que são:**  
Roles definem uma hierarquia de visibilidade dos dados, refletindo a estrutura organizacional. Quem está acima, vê o que está abaixo – como um gerente que vê o trabalho de seu time.[4][5]

**Quando usar:**  
Ao precisar que chefes/acompanhantes vejam dados dos subordinados. Por exemplo, gerente regional deve ver todos os contratos de vendedores da sua região.[4]

**Exemplo prático:**  
- CEO: vê tudo  
- Gerente Regional: vê oportunidades de sua equipe  
- Vendedor: vê só suas oportunidades

**Boas práticas:**  
- Mantenha a hierarquia igual à estrutura real da empresa
- Não crie papéis "vagos" pensando no futuro
- Revise periodicamente para refletir mudanças organizacionais[5][6]

**Documentação:**  
- [Roles Salesforce Documentation (oficial)](https://help.salesforce.com/s/articleView?id=platform.setup_roles_guidelines.htm&language=en_US&type=5)

***

### Profiles (Perfis)

**O que são:**  
Perfis definem o que cada usuário pode fazer dentro do sistema: quais objetos pode acessar, ações (CRUD), campos, abas e recursos. É como o crachá que libera portas (funcionalidades) dentro da empresa.[7][8][9]

**Quando usar:**  
Todo usuário precisa de 1 perfil ao ser criado. Ele serve para delimitar funções principais. Exemplo: um perfil de Vendedor não precisa acesso à configuração do sistema.[7]

**Exemplo prático:**  
- Perfil Vendas: acesso a clientes, leads, oportunidades
- Perfil Suporte: acesso a casos, contas

**Boas práticas:**  
- Perfis são o básico: não crie muitos! Prefira permissões via permission sets, para evitar dificuldade de manutenção
- Use o princípio do menor privilégio: no perfil, dê só o necessário para o papel daquela função[4][7]

**Documentação:**  
- [Profiles Salesforce Documentation (oficial)](https://help.salesforce.com/s/articleView?id=platform.standard_profiles.htm&language=en_US&type=5)
- [Profile Object Reference](https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_profile.htm)

***

### Permission Sets (Conjuntos de Permissões)

**O que são:**  
Permitem conceder permissões adicionais para usuários de forma granular, sem precisar mudar o perfil. Imagine um “adesivo de permissão extra” no crachá de quem precisa.[7]

**Quando usar:**  
Quando um usuário (ou grupo) temporariamente ou adicionalmente precisa de permissão sem alterar o perfil de todos dessa função.  
Exemplo: apoio temporário de funcionários em um projeto que exige recursos extras.[7]

**Exemplo prático:**  
- Usuário de vendas que precisa acesso temporário a configurações de relatórios
- Usuário de suporte que vai acessar um app específico por um período

**Boas práticas:**  
- Use permissões via permission set para tudo que for extra ao cotidiano da função
- Permite flexibilidade sem bagunça no controle de perfis

**Documentação:**  
- [Permission Sets Salesforce Documentation](https://help.salesforce.com/s/articleView?id=sf.perm_sets_overview.htm)

***

### Permission Set Groups

**O que são:**  
Permitem agrupar diversos permission sets em conjuntos atribuíveis de forma simples, facilitando a manutenção de permissões complexas ou de times multidisciplinares.

**Quando usar:**  
Sempre que múltiplas permission sets sejam necessárias para um grupo de pessoas/funções, facilitando atribuição e manutenção.[7]

**Exemplo prático:**  
Permission Set Group “Projeto X” reúne todas as permissões extras necessárias para membros daquele projeto.

**Boas práticas:**  
- Use para cenários recorrentes
- Torna fácil conceder/remover acesso com poucos cliques
- Reduz erros e facilita auditoria

**Documentação:**  
- [Permission Set Groups Salesforce Documentation](https://help.salesforce.com/s/articleView?id=perm_set_groups.htm)

***

### Dica Visual e Prática
Ajuste a estrutura de acesso da sua organização Salesforce em camadas:
1. Defina defaults de OWD (restritivo!)
2. Monte papelaria (Roles = “quem vê o quê”)
3. Perfis: “quem faz o quê”
4. Permission Sets: “liberou algo extra”
5. Permission Set Groups: “grupo de permissões especiais para projetos ou equipes multifuncionais”

Essa segmentação **ajuda no entendimento e manutenção**, principalmente para quem tem TDAH ou TEA, pois permite trabalhar um conceito por vez, com exemplos visuais ou quadros brancos individuais para desenhar o acesso de cada área.

***

### Resumo Analógico

- **OWD:** Muro do condomínio
- **Roles:** Andares do prédio, quem está acima vê o de baixo
- **Perfil:** Crachá do usuário
- **Permission Set:** Adesivo do crachá para liberar portas extras
- **Permission Set Group:** Chave-mestra que agrupa vários adesivos

***

Todos esses links e documentações vão guiar para configuração detalhada e exemplos práticos.[6][8][9][1][5][2][4][7]

[1](https://cloudintellect.in/owd-in-salesforce/)
[2](https://techimplement.com/tech-center/a-practical-approach-to-owd-in-salesforce/)
[3](https://www.crsinfosolutions.com/mastering-data-access-and-security-in-salesforce-a-comprehensive-guide-to-organization-wide-defaults-owd/)
[4](https://www.getgenerative.ai/salesforce-roles-profiles/)
[5](https://www.reco.ai/hub/salesforce-role-hierarchy)
[6](https://help.salesforce.com/s/articleView?id=platform.setup_roles_guidelines.htm&language=en_US&type=5)
[7](https://www.saasguru.co/roles-and-profiles-in-salesforce/)
[8](https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_profile.htm)
[9](https://help.salesforce.com/s/articleView?id=ind.tpm_user_profiles.htm&language=en_US&type=5)
[10](https://help.salesforce.com/s/articleView?id=platform.security_sharing_owd_about.htm&language=en_US&type=5)
[11](https://help.salesforce.com/s/articleView?id=platform.security_owd_external.htm&language=en_US&type=5)
[12](https://help.salesforce.com/s/articleView?id=platform.admin_sharing.htm&language=en_US&type=5)
[13](https://www.theknowledgeacademy.com/blog/owd-in-salesforce/)
[14](https://help.salesforce.com/s/articleView?id=platform.standard_profiles.htm&language=en_US&type=5)
[15](https://s2-labs.com/admin-tutorials/organization-wide-default/)
[16](https://admin.salesforce.com/blog/2023/how-to-write-great-documentation-to-help-with-future-problem-solving)
[17](https://www.elearningsolutions.co.in/understanding-owd-salesforce-beginners-guide/)
[18](https://www.salesforceben.com/salesforce-roles-responsibilities/)
[19](https://help.salesforce.com/s/articleView?language=en_US&id=platform.admin_userprofiles.htm&type=5)
[20](https://www.concret.io/blog/best-practices-for-documenting-salesforce-org)

---

Perfis e permission sets no Salesforce têm funções diferentes e complementares na gestão de acesso dos usuários. Abaixo está uma explicação prática, com exemplos claros e um comparativo:

***

### Diferenças Práticas

|                      | Perfis [6][5]              | Permission Sets [6][8]         |
|----------------------|--------------------------------------|------------------------------------------|
| O que controla       | Configurações padrão e permissões básicas obrigatórias de cada usuário | Permissões adicionais e flexíveis concedidas a usuários conforme necessidade |
| Quantidade por usuário| Apenas 1 perfil é atribuído a cada usuário | Podem ser atribuídos múltiplos permission sets a um usuário |
| Princípio            | Base de acesso, define o mínimo necessário | Expansão do acesso, acrescenta permissões extras sem mexer no perfil principal |
| Como usar            | Defina para cada função/cargo tipo: vendedor, suporte, admin | Para situações especiais ou temporárias: liberar funcionalidade para um projeto específico |
| Exemplo prático      | Perfil Vendas: acesso a Leads, Oportunidades | Permission Set: liberar visualização de Relatórios para alguns membros do time de vendas apenas |
| Boas práticas        | Crie perfis com menos permissões e complemente com permission sets | Use permission sets para evitar criar vários perfis diferentes para pequenas exceções |

***

### Analogia

- **Perfil é como o crachá fixo do colaborador** — ele decide em quais áreas básicas a pessoa pode entrar todo dia.  
- **Permission Set é como um adesivo extra no crachá** — permite entrar em áreas especiais por determinados motivos sem precisar trocar de crachá.

***

### Resumo Visual

- Usuário recebe perfil na criação (obrigatório, 1 por usuário)[5][6]
- Permission set é atribuído conforme necessidade (quantos quiser, flexível)[6][8]

***

### Links de Documentação

- [Controle o acesso aos objetos - Trailhead Salesforce (pt-BR)](https://trailhead.salesforce.com/pt-BR/content/learn/modules/data_security/data_security_objects)
- [Sobre Perfis e Permission Sets (Salesforce Ajuda)](https://help.salesforce.com/s/articleView?id=platform.perm_sets_overview.htm)
- [Comparando papéis, perfis e conjuntos de permissões (Salesforce Developer Guide)](http://www.developerforce.com/guides/br/Fundamentals/Content/adg_securing_data_roles_profiles.htm)

***

Seguindo essa abordagem, recomenda-se criar perfis bem restritos e flexíveis, usando permission sets para ampliar o acesso dos usuários conforme demandas específicas e temporárias, garantindo segurança e organização.[8][5][6]

[1](https://translate.google.com/translate?u=https%3A%2F%2Fwww.salesforceben.com%2Fsalesforce-roles-profiles-permission-sets%2F&hl=pt&sl=en&tl=pt&client=srp)
[2](https://translate.google.com/translate?u=https%3A%2F%2Fblog.netwrix.com%2Funderstanding-roles-profiles-and-permission-sets-in-salesforce%2F&hl=pt&sl=en&tl=pt&client=srp)
[3](https://translate.google.com/translate?u=https%3A%2F%2Fsalesforce.stackexchange.com%2Fquestions%2F119220%2Fexclusive-differences-profiles-vs-permission-sets&hl=pt&sl=en&tl=pt&client=srp)
[4](https://www.youtube.com/watch?v=U-t3seaR40Q)
[5](http://www.developerforce.com/guides/br/Fundamentals/Content/adg_securing_data_roles_profiles.htm)
[6](https://trailhead.salesforce.com/pt-BR/content/learn/modules/data_security/data_security_objects)
[7](https://translate.google.com/translate?u=https%3A%2F%2Fwww.quora.com%2FWhat-is-the-difference-between-sharing-rules-and-permission-sets-in-Salesforce&hl=pt&sl=en&tl=pt&client=srp)
[8](https://translate.google.com/translate?u=https%3A%2F%2Fhelp.salesforce.com%2Fs%2FarticleView%3Fid%3Dplatform.perm_sets_overview.htm%26language%3Den_US%26type%3D5&hl=pt&sl=en&tl=pt&client=srp)
[9](https://www.reddit.com/r/salesforce/comments/uwtojl/profiles_vs_permission_sets/)
[10](https://learn.microsoft.com/pt-br/entra/identity/role-based-access-control/permissions-reference)

---

A Salesforce anunciou que fará uma transição importante na forma de gerenciar permissões dos usuários: as permissões atribuídas diretamente nos perfis serão descontinuadas e, a partir da versão Spring '26, estarão disponíveis apenas via permission sets e permission set groups. Perfis continuarão existindo, mas vão definir apenas configurações básicas (como app padrão, horário de login e layouts), enquanto toda a granularidade de acesso será resolvida por permission sets.[1][2][3]

Porém, na segunda metade de 2025, a Salesforce anunciou um atraso nessa aposentadoria após feedbacks da comunidade, pois ainda existem lacunas funcionais que necessitam de ajustes antes que a transição seja completa. O movimento segue forte: a recomendação oficial é migrar para permission sets e permission set groups o quanto antes e não investir mais tempo em perfis, que não recebem novas funcionalidades.[4][5][6]

### Resumo prático
- Perfis deixam de ser o centro do gerenciamento de permissões; vão virar “porta de entrada básica” (um por usuário).[6][4]
- Permissão detalhada (CRUD, acesso a apps, abas, campos, etc.) será controlada só por permission sets/permission set groups.[2][3]
- Aposentadoria dos perfis foi adiada, mas a Salesforce recomenda migrar já para permission sets.[5]
- Ferramentas como o “Assistente de permissões e acesso do usuário” ajudam a converter perfis em permission sets.[7][8]

### Documentação oficial e fontes
- [Salesforce vai descontinuar permissões em perfis (SalesforceBen, traduzido)](https://translate.google.com/translate?u=https%3A%2F%2Fwww.salesforceben.com%2Fsalesforce-to-retire-permissions-on-profiles-whats-next%2F&hl=pt&sl=en&tl=pt&client=srp)[1]
- [Spring’26 Release: descontinuação das permissões por perfil (LinkedIn)](https://pt.linkedin.com/pulse/salesforce-spring26-release-descontinua%C3%A7%C3%A3o-das-por-perfil-schneider-ig6rf)[2]
- [Futuro da gestão de usuários: Permission Sets (Advanced Communities)](https://advancedcommunities.com/blog/the-future-of-user-management-in-salesforce-switching-from-a-profile-based-access-approach-to-permission-sets/)[3]
- [Notícia de adiamento oficial da aposentadoria (Salesforce Help)](https://help.salesforce.com/s/articleView?id=003834041&language=fr&type=1)[5]
- [Converter perfis em conjuntos de permissões (Salesforce Help)](https://help.salesforce.com/s/articleView?id=platform.perm_uapa_convert_profiles_to_permsets.htm&language=pt_BR&type=5)[8]

A recomendação é começar a planejar e executar a migração para permission sets, pois essa é a direção de longo prazo da Salesforce.[3][4][2]

[1](https://translate.google.com/translate?u=https%3A%2F%2Fwww.salesforceben.com%2Fsalesforce-to-retire-permissions-on-profiles-whats-next%2F&hl=pt&sl=en&tl=pt&client=srp)
[2](https://pt.linkedin.com/pulse/salesforce-spring26-release-descontinua%C3%A7%C3%A3o-das-por-perfil-schneider-ig6rf)
[3](https://advancedcommunities.com/blog/the-future-of-user-management-in-salesforce-switching-from-a-profile-based-access-approach-to-permission-sets/)
[4](https://dynaspecgroup.com/crms-project-success/profiles-are-still-here-but-salesforce-has-moved-on-should-you)
[5](https://help.salesforce.com/s/articleView?id=003834041&language=fr&type=1)
[6](https://www.possibilit.nl/en/article/switch-from-profiles-to-permission-sets-in-time)
[7](https://translate.google.com/translate?u=https%3A%2F%2Fhelp.salesforce.com%2Fs%2FarticleView%3Fid%3Dplatform.perm_uapa_convert_profiles_to_permsets.htm%26language%3Den_US%26type%3D5&hl=pt&sl=en&tl=pt&client=srp)
[8](https://help.salesforce.com/s/articleView?id=platform.perm_uapa_convert_profiles_to_permsets.htm&language=pt_BR&type=5)
[9](https://www.reddit.com/r/salesforce/comments/1gj9bp5/the_end_of_life_of_permissions_on_profiles/)
[10](https://help.salesforce.com/s/articleView?id=platform.admin_userprofiles.htm&language=pt_BR&type=5)
[11](https://help.salesforce.com/s/articleView?id=platform.standard_profiles.htm&language=pt_BR&type=5)
[12](https://pt.linkedin.com/posts/tiagobrsantos_lifterdigital-salesforce-crm-activity-7248652867937460224-Ihm9)
[13](https://help.salesforce.com/s/articleView?id=release-notes.rn_functions_retired.htm&language=pt_BR&release=248&type=5)
[14](https://translate.google.com/translate?u=https%3A%2F%2Fsalesforce.stackexchange.com%2Fquestions%2F119220%2Fexclusive-differences-profiles-vs-permission-sets&hl=pt&sl=en&tl=pt&client=srp)
[15](https://www.reddit.com/r/salesforce/comments/179x27d/salesforce_moving_away_from_profiles_and_towards/)
[16](https://translate.google.com/translate?u=https%3A%2F%2Fs2-labs.com%2Fadmin-tutorials%2Fpermission-sets-object-level-security%2F&hl=pt&sl=en&tl=pt&client=srp)
[17](https://ajuda.rdstation.com/s/article/descontinuacao-da-integracao-e-migracao-para-a-nova-versao?language=pt_BR)
[18](https://www.youtube.com/watch?v=b_5ZI_LasLU)
[19](https://www.reddit.com/r/salesforce/comments/1b5hj85/salesforces_official_guidance_for_migrating_from/)
[20](https://help.salesforce.com/s/articleView?id=release-notes.rn_profiles_and_perms_read_only_new.htm&language=pt_BR&release=230&type=5)
