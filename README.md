<p align="center">
  <img src="assets/logo/logo.png" alt="ClickBoard" width="160">
</p>

<h1 align="center">ClickBoard</h1>

<p align="center">
  Aplicativo acadêmico em <strong>Flutter</strong> para alunos acompanharem
  <strong>avisos, notas e documentos</strong> da faculdade.
</p>

---

## 📌 Sobre o projeto

O **ClickBoard** é um aplicativo **Flutter** originalmente desenvolvido por
[Abhigyan103](https://github.com/Abhigyan103/Clickboard). Na disciplina de
**Análise, Projeto e Desenvolvimento Ágil**, a nossa equipe recebeu o projeto **pronto** (via *fork*)
para dar continuidade, aplicando práticas ágeis (Scrum + XP): backlog, user stories, Planning Poker,
MoSCoW e entregas incrementais por Sprint.

Este documento descreve **o que foi entregue**, **como o projeto está organizado** e **como executá-lo**.

---

## 👥 Equipe (Grupo 4)

| Integrante | Papel |
|---|---|
| Nicolas Soares Oliveira | Product Owner (PO) |
| João Emanuel Silva Neri | Scrum Master (SM) |
| Richard Machado dos Santos | Desenvolvedor |
| Matheus Modro Krueger | Desenvolvedor |
| João Vitor Cirico | Desenvolvedor |

---

## ✅ O que foi entregue na Sprint 1

A história da Sprint 1 (pedida pela professora, no papel de cliente) se desdobrou em duas user stories:

### HU01 — Só a coordenação altera conteúdo oficial
Antes, **qualquer** aluno logado podia renomear ou excluir avisos e documentos. Agora:
- cada usuário tem um **perfil** (aluno ou coordenação);
- **adicionar, renomear e excluir** documentos é permitido **apenas à coordenação** — na interface
  (os botões não aparecem para o aluno) **e** no servidor (regras de segurança do Firestore);
- as regras impedem, inclusive, que um usuário se promova a coordenação por conta própria.

### HU02 — Cadastro e acesso apenas com e-mail institucional
- o app aceita apenas e-mails **`@catolicasc.edu.br`** no cadastro, no login e na recuperação de senha
  (inclusive no acesso via Google), com mensagem clara quando o e-mail é de outro domínio;
- e-mails fora do padrão **não travam o app** nem geram departamento/matrícula incorretos.

> Como parte da continuidade, o armazenamento também foi ajustado para funcionar **sem custo** — ver
> a seção [Arquitetura](#-arquitetura).

---

## 🛠️ Tecnologias

- **Flutter** `3.38.7` · **Dart** `3.10.7` (SDK Dart `>=3.0.5 <4.0.0`)
- **Firebase Authentication** — login (e-mail/senha e Google)
- **Cloud Firestore** — dados (perfis, metadados de avisos e documentos)
- **Supabase Storage** — arquivos (PDFs/imagens dos documentos)
- **Riverpod** — gerência de estado · **go_router** — navegação

> ⚠️ Use as versões acima do Flutter/Dart. Versões muito diferentes podem gerar erros de dependência
> e de API.

---

## 🧱 Arquitetura

O projeto segue **Clean Architecture** com **Riverpod**, separando cada funcionalidade em camadas:

```
lib/src/features/<feature>/
  ├── models/         # modelos de dados (ex.: Document, Notice, Student)
  ├── repository/     # acesso a dados (Firestore, Supabase)
  ├── controllers/    # regras de aplicação e estado (Riverpod)
  └── screens/        # interface (telas e widgets)
```

**Divisão de responsabilidades no backend (tudo em plano gratuito):**

| Precisa | Serviço | Por quê |
|---|---|---|
| Login | Firebase Authentication | e-mail/senha e Google |
| Dados (perfis, avisos, documentos) | Cloud Firestore | gratuito no plano Spark |
| Arquivos (PDF/imagem) | Supabase Storage | gratuito, sem cartão |

O **Firebase Storage** exige o plano pago **Blaze**; por isso os arquivos ficam no **Supabase** e os
metadados no **Firestore** (a URL pública do arquivo é guardada junto do documento). As regras de
segurança do Firestore estão versionadas em [`firestore.rules`](firestore.rules).

---

## ▶️ Como rodar

### 1. Pré-requisitos
- **Flutter `3.38.7`** instalado (`flutter --version` para conferir).
- Os **arquivos de configuração** (contêm chaves, por isso **não ficam no Git**):
  - `lib/firebase_options.dart` e `android/app/google-services.json` (Firebase)
  - `lib/supabase_config.dart` (Supabase — copie de `lib/supabase_config.example.dart` e preencha)
  - 🔑 Peça esses arquivos ao **PO** e cole nos caminhos acima. O time usa **um único** projeto
    Firebase e **um único** projeto Supabase — **não crie projetos próprios**.

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
flutter run -d chrome  # Web: para testar/demonstrar sem emulador
```

| Plataforma | Comportamento |
|---|---|
| **Android** (emulador ou celular) | Experiência completa (inclui notificações e câmera). |
| **Web** (Chrome) | Login, Firestore e documentos (upload/abrir/baixar). Notificações e câmera ficam desligadas — no `lib/main.dart` as notificações só são inicializadas fora da web (`if (!kIsWeb)`), o que **não afeta** o Android. |

<details>
<summary>Preparar a máquina para rodar no Android</summary>

- Instalar o **Android Studio** (traz o Android SDK) e criar um **emulador (AVD)**.
- Ligar o **Modo desenvolvedor** do Windows: `start ms-settings:developers`.
- Aceitar as licenças: `flutter doctor --android-licenses`.
- Validar com `flutter doctor` e rodar `flutter run`.
</details>

---

## 👤 Perfis de usuário (aluno × coordenação)

O perfil é definido pelo campo **`isAdmin`** no documento do usuário na coleção `Users` do Firestore:

- **Aluno** (`isAdmin` = `false`) — vê e baixa avisos/documentos, mas **não** adiciona, renomeia nem exclui.
- **Coordenação** (`isAdmin` = `true`) — gerencia o conteúdo oficial (adicionar, renomear, excluir).

**Para tornar um usuário coordenação:** Firebase Console → Firestore → coleção `Users` → documento do
usuário → definir **`isAdmin` = `true`** → no app, **sair e entrar de novo** para recarregar o perfil.

---

## 📄 Créditos e licença

- **Projeto original:** [Abhigyan103/Clickboard](https://github.com/Abhigyan103/Clickboard) — criado por Abhigyan Singh.
- Distribuído sob a licença **MIT** (ver [`LICENSE`](LICENSE)).
- Continuação acadêmica pela **Equipe 4** — disciplina de Análise, Projeto e Desenvolvimento Ágil.
