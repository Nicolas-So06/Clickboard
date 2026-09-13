<p align="center">
  <img src="assets/logo/logo.png" alt="ClickBoard" width="160">
</p>

<h1 align="center">ClickBoard</h1>

<p align="center">
  Aplicativo acadêmico em Flutter + Firebase para alunos acompanharem
  <strong>avisos, notas e documentos</strong> da faculdade.
</p>

---

## 📌 Sobre o projeto

O **ClickBoard** é um aplicativo **Flutter + Firebase** originalmente desenvolvido por
[Abhigyan103](https://github.com/Abhigyan103/Clickboard). Nesta disciplina de
**Análise, Projeto e Desenvolvimento Ágil**, nossa equipe recebeu o projeto **pronto** (via *fork*)
para **dar continuidade** ao desenvolvimento, aplicando práticas ágeis (Scrum + XP): backlog,
user stories, Planning Poker, MoSCoW e entregas incrementais por Sprint.

> Este README documenta o projeto e o que a equipe fez até o momento.

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

## 🛠️ Tecnologias

- **Flutter** `3.38.7`  ·  **Dart** `3.10.7`  (SDK Dart `>=3.0.5 <4.0.0`)
- **Firebase** (Authentication + Cloud Firestore) — BaaS · _Storage e Cloud Messaging não estão ativos (ver observação abaixo)_
- **Riverpod** — gerência de estado
- **go_router** — navegação/rotas

> ⚠️ Use as versões acima do Flutter/Dart. Versões muito diferentes podem gerar erros de
> dependência e de API (foi o que aconteceu no início do projeto).

---

## ▶️ Como rodar

### 1. Pré-requisitos
- Flutter `3.38.7` instalado (`flutter --version` para conferir).
- Os **2 arquivos de configuração do Firebase** (têm chaves, por isso **não ficam no Git**):
  - `lib/firebase_options.dart`
  - `android/app/google-services.json`
  - 🔑 Peça esses 2 arquivos ao **PO** e cole nos caminhos acima. Todos usam o mesmo projeto
    (`projeto-clickboard`) — **não crie um projeto Firebase próprio**.

### 2. Baixar dependências
```sh
git clone https://github.com/Nicolas-So06/Clickboard.git
cd Clickboard
flutter pub get      # o Flutter também regenera os arquivos de plugin automaticamente
flutter analyze      # deve terminar com 0 erros
```

---

## 💻 Rodar no Android **ou** na Web?

```sh
flutter run            # Android: com um emulador aberto ou um celular (depuração USB)
flutter run -d chrome  # Web: para testar rápido a UI, login e Firestore
```

Durante o desenvolvimento a máquina do PO **não tinha espaço** para instalar o Android Studio
(emulador), então adaptamos o projeto para **também rodar na Web** e validar login/dados.

**Importante:** essa adaptação **não quebra o Android**. No `lib/main.dart` as notificações são
inicializadas apenas fora da web (`if (!kIsWeb)`), então:

| Plataforma | Comportamento |
|---|---|
| **Android** (emulador ou celular) | Funciona **completo**, como sempre (notificações, câmera, documentos etc.). **Não precisa reverter nada.** |
| **Web** (Chrome) | Roda para testar **UI, login (Auth) e Firestore**. Ficam **desligados**: notificações, câmera/foto de perfil (Storage) e o *web scraping* de avisos pode falhar por **CORS**. |

> 💡 Ou seja: quem tiver emulador Android é só rodar `flutter run` normalmente. Quem não tiver,
> pode usar `flutter run -d chrome` para desenvolver e demonstrar.

### Preparar a máquina para o Android (se ainda não tiver)
- Instalar o **Android Studio** (traz o Android SDK) e criar um **emulador (AVD)**.
- Ligar o **Modo desenvolvedor** do Windows (`start ms-settings:developers`).
- Aceitar as licenças: `flutter doctor --android-licenses`.
- Validar com `flutter doctor` e rodar `flutter run`.

---


## ✅ O que a equipe fez até agora

**Sprint 0 — "o app builda e roda":**
- Correção dos erros de build herdados (dependências `carousel_slider` e `font_awesome_flutter`
  reinstaladas; ajuste de tema para a API nova do Flutter).
- **Firebase configurado** (projeto `projeto-clickboard`): Authentication e Cloud Firestore ativos e testados.
- Adaptação para rodar também na **Web**, sem quebrar o Android.

**Migração Storage → Firestore (avisos e documentos):**
- Como o Storage exige plano pago, os **avisos** e **documentos** passaram a ser lidos e gravados
  no **Cloud Firestore** (gratuito), no lugar do Firebase Storage.
- Resultado: criar/listar/renomear/excluir funciona sem custo, e a tela não trava mais no
  carregamento (mostra estado vazio quando não há itens).

**Sprint 1 — em andamento (história de usuário):**
- **HU01** — apenas a **coordenação** pode renomear/excluir avisos e documentos oficiais.
- **HU02** — o cadastro aceita apenas **e-mail institucional** válido, tratando e-mails fora do padrão.

---

## ℹ️ Observação sobre o Firebase Storage

O **Storage** **não está ativo**: projetos Firebase novos exigem o plano pago **Blaze** (com cartão)
para habilitá-lo, e o grupo optou por **não vincular cartão**. Por isso, avisos e documentos foram
migrados para o **Firestore** (grátis). As features que ainda dependem de Storage (foto de perfil,
imagens do carrossel e arquivos de notas) **permanecem desativadas** — não fazem parte da Sprint 1.

---

## 🎥 Vídeo da Sprint 1

> _(adicionar aqui o link do vídeo demonstrando a história de usuário da Sprint 1 funcionando)_

---

## 📄 Créditos e licença

- **Projeto original:** [Abhigyan103/Clickboard](https://github.com/Abhigyan103/Clickboard) — criado por Abhigyan Singh.
- Distribuído sob a licença **MIT** (ver arquivo [`LICENSE`](LICENSE)).
- Continuação acadêmica pela **Equipe 4** na disciplina de Análise, Projeto e Desenvolvimento Ágil.
