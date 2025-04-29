# Introdução
Olá pequeno ser humano. Tudo bem?

Quando falamos sobre Salesforce, percebi que seria extremamente útil que, antes de sair falando sobre serviços, capacidades, casos de uso e afins, é de suma importância dar alguns contextos.
Neste caso é até interessante abordar de forma separada, visto que falaremos de um dos muitos serviços da Salesforce.

Comecemos, pois.

# Assuntos abordados
O Objetivo é trazer para a discussão a maneira de 'interpretar' algumas coisas quando falamos sobre Salesforce.
- O que é, afinal, o Salesforce?
- Como o Salesforce Platform se relaciona com os demais serviços do universo Salesforce?
- Como o Salesforce Platform se relaciona com as funcionalidades de desenvolvimento (no/low e high code)?

## O que é, afinal, Salesforce?
Antes de falar, vamos pensar sobre o que queremos dizer quando falamos "Salesforce".

Aí, você pode pensar

> Como assim?

Pois bem... No livro **Practical Salesforce Architecture** do *Paul McCollum*, essa discussão é trazida. Parafrazeando e traduzindo o que é trazido no livro em *"What's in a name?"*, em uma linguagem coloquial, você pode estar se referindo à três coisas:
- A empresa
- A plataforma onde a maior parte dos componentes é desenvolvida e onde eles funcionam
- Uma funcionalidade específica (como Sales Cloud, mencionada no trecho do livro como sendo a origem de tudo)
- E aqui adiciono ainda que pode ser o nome da **Licença** dentro de um serviço contratado (no caso, a Salesforce é a licença mais completa, mas falaremos disso em outra ocasião).

Numa ordem oposta (interpretando a parte final do trecho) seria:
- A funcionalidade Sales Cloud
- Que fica encapsulada na plataforma Salesforce
- Que é gerenciada pela empresa Salesforce

Entendendo este ponto, começamos a entender melhor esse universo.

### Estrutura inicial
Quando você contrata um serviço Salesforce (vamos seguir com o *Sales Cloud*), você 'ganha' uma **Org**. A Org é sua organização. É o espaço por onde serão acessados e configurados os serviços Salesforce (neste exemplo, o *Sales Cloud*). 
Essa **Org** tem o serviço *Salesforce Platform* que é a fundação na qual está o serviço *Sales Cloud*. E é através do Salesforce Platform que existe a possibilidade de criação e configuração de "Aplicativos" (aqui entre aspas porque é um aplicativo dentro da **Org**, que não necessariamente seria um aplicativo).
Sua **Org** está dentro de uma *** instância Salesforce ***.

> O que isso significa?

Uma *** instância Salesforce *** é o ambiente físico e lógico onde sua **Org** está hospedada. Ela possui várias outras Orgs (que podem ou não pertencer à mesma empresa contratante). Cada ***instância*** está localizada em uma região geográfica. Elas são protegidas e isoladas, ou seja, os dados e demais componentes da sua **Org** não estão disponíveis para outras Orgs.
Para isso, a empresa Salesforce trabalha com o modelo *multi-tennant*. Como não é escopo desse material, você pode se informar melhor sobre esse modelo clicando neste [link](https://architect.salesforce.com/fundamentals/platform-multitenant-architecture).

## Como o Salesforce Platform se relaciona com os demais serviços do universo Salesforce?


## Como o Salesforce Platform se relaciona com as funcionalidades de desenvolvimento (no/low e high code)?


# Encerramento




#####################################################################


    public static void...



-------
# rascunho-automacao-doc
Rascunhos de scripts para automação de rastreamento organização salesforce

# Notas:
## Diretorios:
- _docs: guarda documentação e scripts usados no desenvolvimento. Inicia por " _ " para ficar separado dos demais diretórios da organização.
	- /logs: armazena os logs gerados
		- /json
			- audit-package-xml.json (ideia)
			- audit-audit-trails.json (ideia)
		- /md
			- audit-package-xml.md
			- audit-audit-trails.md (*)
	- /scripts: armazena os scripts usados no desenvolvimento e documentação
		- /devel: auxiliam no desenvolvimento e audit de alterações
		- /doc: auxiliam na documentação usando retrieve
	- /org: armazena documentação dos componentes da organização
		- /obj
			- /custom
			- /standard
		- /code
			- /api
			- /class
			- /trigger
		- /components
			- /standard
			- /aura
			- /lwc/
			- visualforce
		- (...)
