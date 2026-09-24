# SwiftLint warning burndown

## Atalho: só o link

Se você chegou aqui pela sequência do
[`10`](10-swiftlint-quality-gates-install.md) →
[`11`](11-swift-file-size-refactor.md) e agora quer zerar o que sobrou
(`print` direto, `file_length` em warn, qualquer outra regra que o
projeto já tinha no SwiftLint), cole esta linha:

```
Leia https://raw.githubusercontent.com/soumatheusgomes/vibe-coding-toolkit/main/docs/prompts/12-swiftlint-warning-burndown.md
e execute o prompt que está nesse arquivo neste projeto, para o conjunto
inteiro de avisos restantes. Descubra sozinho os comandos de lint, teste,
typecheck e build lendo o xcodeproj, o Package.swift e scripts/lint.sh —
não o package.json.
```

O resto deste documento é o mesmo prompt, aberto.

## Quando usar

Se o projeto ainda não tem o teto de linhas via SwiftLint, use antes o
[`10-swiftlint-quality-gates-install.md`](10-swiftlint-quality-gates-install.md).
Se os avisos que você quer zerar são especificamente de **tamanho de
arquivo**, vá pro
[`11-swift-file-size-refactor.md`](11-swift-file-size-refactor.md).

Se o projeto é JavaScript ou TypeScript, use o
[`02-eslint-warning-burndown.md`](02-eslint-warning-burndown.md).

Use este prompt quando você tem uma pilha de warnings do SwiftLint pra
zerar — ou a medição do 10 deixou uma regra em `warning` com linha de
base — sem que "só corrigir os warnings" vire um refactor grande.

Se o 10 mediu **zero** avisos e as duas regras já estão em `error`, este
prompt para no passo 0. Não inventa trabalho.

## Por que funciona

É o mesmo mecanismo do 02: transformar decisão implícita em decisão
explícita, e alegação em comando. Contagem real agora, portão de decisão
na parte cara, critérios como comandos, ondas de arquivos disjuntos,
pegadinhas copiadas em cada briefing, checklist só riscado rodando o
comando de novo.

Em Swift o typecheck **é** o `xcodebuild` / `swift build`. Não existe
`tsc --noEmit` separado. Isolação e Sendable do Swift 6 aparecem no
compilador, não no SwiftLint — uma extração "só de lint" que quebra
concorrência ainda é mudança de comportamento.

## Como adaptar os placeholders

- **`[RULE_NAME]`** — a regra do SwiftLint, ou o conjunto inteiro. Ex.:
  `no_direct_print`, `file_length`.
- **`[LINT_COMMAND]`** — `./scripts/lint.sh` (com `DEVELOPER_DIR`).
- **`[TYPECHECK_COMMAND]`** — `xcodebuild … build` ou `swift build`.
- **`[TEST_COMMAND]`** — o scheme de teste, ou `none`.
- **`[BUILD_COMMAND]`** — em app Xcode, costuma ser o mesmo que o
  typecheck. Não invente `verify-*.sh` se o projeto já disse que não tem.
- **`[STACK/FRAMEWORK]`** — ex.: "Swift 6, AppKit + SwiftUI, macOS".

## O prompt

```
You are planning and executing a SwiftLint warning burn-down for
[RULE_NAME] (or the full warning set) in this repo. Do not start fixing
anything until the plan below is written and the decision gate in step 1
is answered.

If this project is JavaScript or TypeScript, stop and use
02-eslint-warning-burndown.md.

Discover lint / typecheck / test / build by reading the xcodeproj,
Package.swift, scripts/lint.sh and the README. Do not look for
package.json.

## 0. Ground truth
Run `[LINT_COMMAND]` right now and report the actual current count —
total warnings, broken down by rule and by file. Do not reuse a number
from an earlier run, a commit message, or memory. Set DEVELOPER_DIR.
If SwiftLint crashes on sourcekitdInProc, that is not a zero-warning
result — fix the environment and re-run.

If the count is already zero for the requested set, stop and say so.
Do not loosen a rule or split a file to create work.

If the remaining warnings are only file_length, stop this prompt and
point to 11-swift-file-size-refactor.md. Size splits are a different
kind of work.

## 1. 🔴 Decision gate — answer before any implementation
Find the single riskiest or most expensive part of this burn-down —
usually one rule responsible for a large share of the count,
concentrated in files where "fixing" it is expensive or risky (e.g.
file_length on a cohesive parser, or no_direct_print in a file that
is the log adapter). State it with real numbers. Then present options:

- **(A) Fix every violation fully.** Default if there's no response.
- **(B) Fix most, track the rest as tracked debt.** Leave the expensive
  tail as an explicit, visible exception (`// swiftlint:disable` with a
  reason, or custom_rules.excluded for the log adapter) — not a silent
  suppression.
- **(C) Re-scope or loosen the rule itself.** ⚠️ **This is a config
  change, not a warning fix — say so explicitly. Never present it as if
  the code got cleaner.** Raising MAX_LINES is option C.

Wait for a decision before implementing anything in this area.
Everything outside the flagged risk area proceeds regardless.

## 2. Success criteria — commands, not prose
State every criterion as a command and its expected output, e.g.:
- `[LINT_COMMAND] shows 0 warnings for [RULE_NAME]`
- `[TYPECHECK_COMMAND]` clean
- `[TEST_COMMAND]` green (or skipped because it is none)
- **Zero behavior change.** Any fix that isn't a pure mechanical
  extraction/rename/move gets pulled out of this burn-down.

Replacing `print` with `Logger` is mechanical only when the message and
the moment of logging stay the same. Changing what gets logged is a
behavior change.

## 3. Break the work into waves
Group the remaining violations into ordered, file-disjoint waves. For
each task: task ID, exact file scope (`Files:`), `Depends-on:`, and the
specialist role. Use 05-parallel-wave-dispatch.md in this same folder.

## 4. Pitfalls — copy verbatim into every task brief
List every concrete gotcha specific to this rule and this codebase —
e.g. SourceKit needs DEVELOPER_DIR; file_length has no per-rule ignore
key; extracting a helper can break Swift 6 sendability; `print` in a
preview provider; custom_rules with match_kinds miss comments on
purpose. A subagent sees only its own brief.

## 5. Reviewer sign-off
For each wave, name every specialist reviewer required. Full-diff pass
at normal rigor, not a lighter one because it's "only" lint.

## 6. Final checklist — mark only by re-running
- [ ] `[LINT_COMMAND]` shows 0 warnings for [RULE_NAME] (or the count
      agreed at the decision gate)
- [ ] `[TYPECHECK_COMMAND]` clean
- [ ] `[TEST_COMMAND]` green or none
- [ ] `[BUILD_COMMAND]` succeeds
- [ ] Every suppression (`swiftlint:disable` or custom_rules.excluded)
      is listed with its justification — or the list is empty
- [ ] Every non-mechanical fix pulled out under step 2 is listed
- [ ] All reviewer sign-offs from step 5 are complete

Codebase: [STACK/FRAMEWORK]. Rule(s) in scope: [RULE_NAME].
```

## Exemplo de uso

Imagine que o 10 deixou `no_direct_print` em `warning` com 12 chamadas,
8 delas num `DebugPanel.swift` que *é* o console do app. Você
preencheria:

- `[RULE_NAME]` → conjunto restante (`no_direct_print`)
- `[LINT_COMMAND]` → `./scripts/lint.sh`
- `[TYPECHECK_COMMAND]` → `xcodebuild -scheme App -destination 'platform=macOS' build`
- `[TEST_COMMAND]` → `none`
- `[BUILD_COMMAND]` → o mesmo `xcodebuild`
- `[STACK/FRAMEWORK]` → "Swift 6, SwiftUI, macOS"

O agente conta 12 de verdade. No portão, aponta o `DebugPanel` como o
ponto caro e oferece A/B/C. Sem resposta, assume A no resto (as 4
chamadas baratas viram `Logger`) e espera pra decidir o painel. Não
sobe o teto de linhas. Não mistura isso com o 11.

## Dicas

- O portão do passo 1 é onde está a maior parte do trabalho real.
- Combine o passo 3 com
  [`05-parallel-wave-dispatch.md`](05-parallel-wave-dispatch.md).
- `swiftlint:disable file_length` sem comentário de motivo é a mesma
  coisa que um `eslint-disable` silencioso — o 02/12 pedem a lista.
