<p align="center">
  <img src="assets/logo/logo.png" alt="ClickBoard" width="160">
</p>

<h1 align="center">ClickBoard</h1>

<p align="center">
  Aplicativo acadêmico em Flutter para alunos acompanharem avisos, notas e documentos da faculdade.
</p>

---

## Sobre o projeto

O ClickBoard é um aplicativo Flutter criado originalmente por
[Abhigyan103](https://github.com/Abhigyan103/Clickboard). Na disciplina de Análise, Projeto e
Desenvolvimento Ágil, a nossa equipe recebeu o projeto já pronto (por meio de um fork) para dar
continuidade. Ao longo das Sprints fomos aplicando práticas ágeis de Scrum e XP, como backlog, user
stories, Planning Poker, MoSCoW e entregas incrementais a cada Sprint.

Este documento conta o que foi entregue, como o projeto está organizado e como rodá-lo.

---

## Equipe (Grupo 4)

Os papéis mudam a cada Sprint, como manda a prática de XP.

| Integrante | Papel na Sprint 1 | Papel na Sprint 2 |
|---|---|---|
| Nicolas Soares Oliveira | Product Owner (PO) | Desenvolvedor |
| João Vitor Cirico | Desenvolvedor | Product Owner (PO) |
| João Emanuel Silva Neri | Scrum Master (SM) | Desenvolvedor |
| Richard Machado dos Santos | Desenvolvedor | Scrum Master (SM) |

O Matheus Modro Krueger saiu do time na Sprint 2.

---

## O que foi entregue na Sprint 1

A história pedida pela professora (no papel de cliente) virou duas user stories.

### HU01: só a coordenação altera conteúdo oficial

Antes, qualquer aluno logado conseguia renomear ou excluir avisos e documentos. Agora:

- cada usuário tem um perfil, que pode ser aluno ou coordenação;
- adicionar, renomear e excluir documentos passou a ser só da coordenação. Isso vale tanto na tela
  (os botões não aparecem para o aluno) quanto no servidor (as regras de segurança do Firestore);
- as regras também impedem que um usuário se promova a coordenação por conta própria.

### HU02: cadastro e acesso só com e-mail institucional

- o app aceita apenas e-mails `@catolicasc.edu.br` no cadastro, no login e na recuperação de senha,
  inclusive no acesso pelo Google. Quando o e-mail é de outro domínio, aparece uma mensagem clara;
- e-mails fora do padrão não travam o app nem geram departamento ou matrícula errados.

Como parte da continuidade, também ajustamos o armazenamento para funcionar sem custo. Explicamos
isso na seção [Arquitetura](#arquitetura).

---

## Sprint 2 (N2)

Na Sprint 2 o time passou a trabalhar com TDD, refatoração com teste de regressão, revisão por Pull
Request e integração contínua. Esta seção soma ao que já foi feito na N1.

### Sprint Goal

Deixar a autorização do conteúdo oficial confiável no servidor, e não só na tela, e corrigir a
edição do perfil, tudo com testes automatizados e CI.

### User Stories

#### US-01: autorização de avisos e documentos no servidor

Como coordenação, quero que apenas usuários autorizados consigam renomear, excluir ou enviar avisos
e documentos, mesmo que tentem fazer isso por fora da interface, para que o conteúdo oficial não seja
alterado por quem tenta contornar o aplicativo.

Verificação INVEST: é independente da US-02; é negociável, já que Firestore e Storage podem evoluir
em etapas; tem valor direto de segurança; é estimável; é pequena o bastante para caber num Sprint; e
é testável pelas regras no emulador.

Critérios de aceite:

- Dado um aluno, quando ele chama o servidor direto para gravar ou apagar em `Documents` ou
  `Notices`, então a regra recusa.
- Dado um aluno, quando ele tenta mudar o próprio `isAdmin`, então é recusado.
- Dada a coordenação, quando ela envia, renomeia ou apaga pelo app, então funciona.
- Dado um aluno, quando ele chama o Storage direto para apagar um arquivo, então o servidor recusa e
  o arquivo continua lá.

#### US-02: edição do nome no perfil

Como aluno, quero alterar meu nome no perfil e vê-lo salvo, para manter meus dados corretos no
aplicativo.

Verificação INVEST: é independente; é negociável; tem valor para o usuário; é estimável; é pequena; e
é testável por testes de unidade e de repositório.

Critérios de aceite:

- Dado um aluno, quando ele altera o nome e salva, então o nome fica salvo e continua lá depois de
  reabrir o app.
- Dado um nome vazio ou só com espaços, quando ele salva, então recebe um erro em português e nada é
  gravado.
- Dado que a gravação falhou, quando ele salva, então recebe uma mensagem clara, sem sucesso falso
  nem erro silencioso.

### Backlog do Sprint 2

A priorização (MoSCoW) e a estimativa (Planning Poker) foram definidas no Planning (issue #1).

| Item | Descrição | MoSCoW | Pts |
|---|---|---|---|
| T3 (US-01) | Autorização no servidor, com as regras e o spike do storage | Must | 13 |
| T4 (US-02) | Corrigir o nome do perfil que não salva | Must | 5 |
| T1 | CI no GitHub Actions e os primeiros testes | Must | 5 |
| T6 | Remover código herdado da JGEC (code smell) | Should | 3 |
| T2 | Injetar o storage no DocumentController (testabilidade) | Should | 3 |
| T5 | Tratamento de erro: catch vazio e BuildContext depois do await | Should | 3 |

Pendência da N1 trazida para a Sprint 2: a adaptação do `regValidate` (matrícula fora do padrão da
JGEC) tinha ficado em aberto e foi concluída junto com a US-02.

### Definition of Done

Uma história fica pronta quando: tem teste automatizado cobrindo o caminho principal; não introduz
code smell conhecido; foi revisada por um colega em Pull Request; está mergeada na `main`; e a CI
está verde (`flutter analyze` e `flutter test`).

### Catálogo de code smells

| # | Onde | Smell | Refatoração aplicada | Teste de regressão | Tipo |
|---|---|---|---|---|---|
| 1 | `validators.dart` (`regValidate`) | A validação herdada da JGEC barrava a matrícula "N/A", travava o `Form.validate()` e impedia salvar o perfil | Passou a aceitar matrícula vazia ou "N/A", e o padrão da JGEC virou uma constante com nome | `test/core/validators_test.dart` | Bug |
| 2 | `profile_repository.dart` (`editProfile`) | Gravava o documento inteiro, reenviava o `isAdmin` como string e fazia a regra do servidor recusar o update | Passou a atualizar só os campos editáveis (nome e matrícula) | `test/features/profile/profile_repository_test.dart` | Bug |
| 3 | `student_model.dart` | Código morto: regex e derivações do padrão `@...jgec.ac.in`, que nunca rodavam, já que o app só aceita `@catolicasc.edu.br` | Removemos os métodos mortos e deixamos o `fromEmail` com valores neutros | `test/models/student_model_test.dart` | Refatoração |
| 4 | `supabase_storage_service.dart` e `supabase/policies.sql` | A anon key embutida no app autorizava escrita e exclusão direto no Storage | As chamadas ao Storage passaram a enviar o JWT do usuário no lugar da anon key, e as políticas do bucket só liberam escrita para quem está em `public.admins` (a coordenação), através do `is_coordinator()` | `test/features/documents/supabase_storage_service_test.dart` (lado do cliente) mais a evidência manual da recusa no servidor | Bug |
| 5 | `firestore.rules` (`Users` e `isCoordinator`) | A leitura direta de `resource.data.isAdmin` dava erro em contas criadas antes da HU01, onde o campo não existia, e a regra acabava recusando a edição do nome | Passamos a usar `get('isAdmin', false)` nos dois lados da comparação e no `isCoordinator()` | `firebase/rules-tests/rules.test.js` (aluno antigo sem `isAdmin`) | Bug |
| 6 | `result.dart` e `documents.dart` (ramo `error` do `when`) | Código duplicado e widget errado: o erro devolvia um `Center` dentro do `CustomScrollView` e a tela inteira ficava vermelha quando a busca falhava | Criamos um widget único, o `SliverMessage` (a mensagem dentro de um `SliverToBoxAdapter`), usado nas duas telas | `test/features/result/result_screen_test.dart`, `test/features/documents/document_screen_test.dart` | Bug |
| 7 | `signup_form.dart` (callback do `registerUser`) | Uso de `ref` e `context` depois do `dispose`: o roteador leva para a verificação de e-mail e descarta o formulário antes do callback, gerando o erro "Cannot use ref after the widget was disposed" | Fizemos um retorno antecipado com `if (!mounted) return;`, e o usuário já é carregado pelo `authStateChanges` no `main.dart` | `test/features/authentication/signup_form_test.dart` | Bug |

Limitação declarada da US-01 para os arquivos: a restrição de escrita no Storage só vale depois que o
`supabase/policies.sql` é aplicado no painel do Supabase, com o Third-Party Auth do Firebase ativo e
os uids da coordenação cadastrados em `public.admins`. O teste automatizado do Storage prova o lado
do cliente (o envio do JWT e o tratamento da recusa), e a recusa pelo servidor é comprovada por
evidência manual. Os detalhes estão em `docs/sprint-2/spike-autorizacao-storage.md`.

### Como rodar os testes

```sh
# Testes Dart (unidade e repositório)
flutter test

# Testes das regras do Firestore (precisa de Node e JDK/Java)
cd firebase/rules-tests && npm install && cd ../..
firebase emulators:exec --only firestore --project=demo-clickboard "npm --prefix firebase/rules-tests test"
```

As regras rodam sobre um emulador em Java. Na máquina local, quando não tem Java, a execução acontece
na CI.

### Links

- Pipeline de CI (GitHub Actions): <https://github.com/Nicolas-So06/Clickboard/actions/workflows/ci.yaml>
- Pull Requests principais: [#29, Sprint 2 (N2)](https://github.com/Nicolas-So06/Clickboard/pull/29) (com revisão)
- Vídeo de demonstração: <https://youtu.be/7nWzzacQwPI>

---

## Tecnologias

- Flutter `3.38.7` e Dart `3.10.7` (SDK Dart `>=3.0.5 <4.0.0`)
- Firebase Authentication para o login (e-mail/senha e Google)
- Cloud Firestore para os dados (perfis e metadados de avisos e documentos)
- Supabase Storage para os arquivos (PDFs e imagens dos documentos)
- Riverpod para o estado e go_router para a navegação

Use as versões acima do Flutter e do Dart. Versões muito diferentes podem gerar erros de dependência
e de API.

---

## Arquitetura

O projeto segue Clean Architecture com Riverpod, separando cada funcionalidade em camadas:

```
lib/src/features/<feature>/
  ├── models/         # modelos de dados (ex.: Document, Notice, Student)
  ├── repository/     # acesso a dados (Firestore, Supabase)
  ├── controllers/    # regras de aplicação e estado (Riverpod)
  └── screens/        # interface (telas e widgets)
```

Como dividimos o backend (tudo em plano gratuito):

| Precisa | Serviço | Por quê |
|---|---|---|
| Login | Firebase Authentication | e-mail/senha e Google |
| Dados (perfis, avisos, documentos) | Cloud Firestore | gratuito no plano Spark |
| Arquivos (PDF e imagem) | Supabase Storage | gratuito e sem cartão |

O Firebase Storage exige o plano pago Blaze. Por isso os arquivos ficam no Supabase e os metadados no
Firestore (a URL pública do arquivo é guardada junto do documento). As regras de segurança do
Firestore estão versionadas em [`firestore.rules`](firestore.rules).

---

## Como rodar

### 1. Pré-requisitos

- Ter o Flutter `3.38.7` instalado (confira com `flutter --version`).
- Ter os arquivos de configuração. Eles contêm chaves, então não ficam no Git:
  - `lib/firebase_options.dart` e `android/app/google-services.json` (Firebase)
  - `lib/supabase_config.dart` (Supabase; copie de `lib/supabase_config.example.dart` e preencha)
  - Peça esses arquivos ao PO e cole nos caminhos acima. O time usa um único projeto Firebase e um
    único projeto Supabase, então não crie projetos próprios.

### 2. Baixar dependências

```sh
git clone https://github.com/Nicolas-So06/Clickboard.git
cd Clickboard
flutter pub get      # o Flutter também regenera os arquivos de plugin automaticamente
flutter analyze      # deve terminar com 0 erros
```

### 3. Executar

```sh
flutter run            # Android: com um emulador aberto ou um celular (depuração USB)
flutter run -d chrome  # Web: para testar ou demonstrar sem emulador
```

| Plataforma | Comportamento |
|---|---|
| Android (emulador ou celular) | Experiência completa, com notificações e câmera. |
| Web (Chrome) | Login, Firestore e documentos (upload, abrir e baixar). Notificações e câmera ficam desligadas, porque no `lib/main.dart` as notificações só são iniciadas fora da web (`if (!kIsWeb)`), o que não afeta o Android. |

<details>
<summary>Preparar a máquina para rodar no Android</summary>

- Instalar o Android Studio (que já traz o Android SDK) e criar um emulador (AVD).
- Ligar o Modo desenvolvedor do Windows: `start ms-settings:developers`.
- Aceitar as licenças: `flutter doctor --android-licenses`.
- Validar com `flutter doctor` e rodar `flutter run`.
</details>

---

## Perfis de usuário (aluno e coordenação)

O perfil é definido pelo campo `isAdmin` no documento do usuário, na coleção `Users` do Firestore:

- Aluno (`isAdmin` igual a `false`): vê e baixa avisos e documentos, mas não adiciona, não renomeia e
  não exclui.
- Coordenação (`isAdmin` igual a `true`): gerencia o conteúdo oficial, podendo adicionar, renomear e
  excluir.

Para tornar um usuário coordenação, vá no Firebase Console, abra o Firestore, encontre a coleção
`Users`, abra o documento do usuário e defina `isAdmin` igual a `true`. Depois, no app, saia e entre
de novo para recarregar o perfil.

---

## Créditos e licença

- Projeto original: [Abhigyan103/Clickboard](https://github.com/Abhigyan103/Clickboard), criado por
  Abhigyan Singh.
- Distribuído sob a licença MIT (veja o arquivo [`LICENSE`](LICENSE)).
- Continuação acadêmica feita pela Equipe 4, na disciplina de Análise, Projeto e Desenvolvimento Ágil.
