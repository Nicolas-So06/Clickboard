# Spike — Autorização "de verdade" de avisos e documentos (US-01 / T3)

> Status: **proposta para ratificação** na sessão em dupla (Driver/Navigator) + PO.
> Sprint 2. Relacionado às issues **#4 (T3)** e **#1 (T0)**.

## Problema

O cliente pediu que a restrição de quem pode apagar/renomear/enviar avisos e
documentos valha **no servidor**, não só escondendo o botão na tela — *"pense em
quem tenta contornar a interface"*.

Hoje o conteúdo do ClickBoard está dividido em dois serviços:

1. **Metadados** (avisos e documentos) no **Cloud Firestore** — já protegidos por
   `firestore.rules` (só a coordenação escreve; `isAdmin` imutável). **Faltava o
   teste que comprova** → entregue em `firebase/rules-tests/rules.test.js`.
2. **Arquivos** (PDFs/imagens) no **Supabase Storage** — **vulnerável**:
   `lib/src/core/services/supabase_storage_service.dart:15-18` envia a
   **anon key** (embutida no app, em `supabase_config.dart`) no header
   `Authorization`. Quem extrai a chave do APK chama o Storage direto e
   **apaga/sobe arquivos sem passar por autorização alguma**. A UI não protege.

## Opções avaliadas

| Opção | Descrição | Prova no servidor | Custo | Esforço |
|---|---|---|---|---|
| **A. Supabase + Auth do Firebase (RLS)** | Mantém arquivos no Supabase; revoga escrita anônima no bucket e exige um JWT do Firebase; políticas RLS liberam só `authenticated`/coordenação | RLS do Supabase | Gratuito | Médio |
| B. Migrar arquivos p/ Firebase Storage + `storage.rules` | Unifica no Firebase; testável no mesmo emulador | `storage.rules` | **Pago (plano Blaze)** ❌ | Médio/alto |
| C. Edge Function no Supabase | Função server-side valida a autorização antes de gravar/apagar | Código da função | Gratuito | Alto |

## Decisão proposta: **Opção A**

**Por quê:** mantém a arquitetura gratuita atual (motivo original de o time ter
escolhido o Supabase em vez do Firebase Storage, que exige o plano pago Blaze) e
move a autorização para o servidor via RLS, eliminando a dependência da anon key
para escrita.

### O que entra (implementação — sessão em dupla)

1. **Revogar escrita anônima** no bucket de documentos e aplicar as políticas
   versionadas em [`supabase/policies.sql`](../../supabase/policies.sql).
2. **Autenticar as chamadas ao Storage** com o JWT do usuário (Supabase
   Third-Party Auth com o Firebase), em vez da anon key, no
   `SupabaseStorageService`.
3. **Teste de aceite** que falha hoje: como aluno, chamar o Storage direto para
   apagar e exigir **recusa do servidor** (o arquivo continua lá).

### Já entregue nesta tarefa (parte testável)

- Teste das `firestore.rules` no emulador (`firebase/rules-tests/`), cobrindo:
  aluno não escreve em `Documents`/`Notices`, coordenação escreve, `isAdmin`
  imutável, leitura exige autenticação.
- Políticas do Supabase versionadas (`supabase/policies.sql`) — a aplicar no
  projeto durante a implementação.
- Configuração do emulador em `firebase.json`.

## Critérios de aceite (status)

- [x] Aluno grava/apaga em `Documents`/`Notices` direto → **regra recusa**
      (coberto pelo teste das regras).
- [x] Aluno tenta mudar o próprio `isAdmin` → **recusado** (coberto).
- [x] Coordenação envia/renomeia/apaga pelo app → **funciona** (coberto).
- [ ] Aluno chama o Storage direto para apagar → **servidor recusa**
      (depende da implementação da Opção A — sessão em dupla).
