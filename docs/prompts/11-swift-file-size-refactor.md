# Quebrar os arquivos gigantes que o teto de linhas revelou (Swift)

## Atalho: só o link

Depois que o prompt
[`10`](10-swiftlint-quality-gates-install.md) já mediu e te deu a lista
de arquivos acima do teto, cole esta linha:

```
Leia https://raw.githubusercontent.com/soumatheusgomes/vibe-coding-toolkit/main/docs/prompts/11-swift-file-size-refactor.md
e execute o prompt que está nesse arquivo neste projeto. Use MAX_LINES=350,
BATCH_SIZE=3 e RULE_ID=file_length. Descubra sozinho os comandos de lint,
teste e typecheck lendo o xcodeproj, o Package.swift e scripts/lint.sh —
não o package.json.
```

O resto deste documento é o mesmo prompt, aberto.

## Quando usar

Use este prompt depois que o teto de tamanho por arquivo já está
instalado via SwiftLint e o linter já apontou quais arquivos estouraram
— normalmente logo após o
[`10-swiftlint-quality-gates-install.md`](10-swiftlint-quality-gates-install.md).

Se a lista do 10 estiver **vazia**, não rode este prompt. Zero arquivos
acima do teto é o resultado certo, não um 11 que precisa inventar corte.

Se o projeto é JavaScript ou TypeScript, use o
[`09-file-size-refactor.md`](09-file-size-refactor.md) com
`RULE_ID=quality/max-lines`.

Não use pra zerar avisos de lint em geral — isso é o
[`12-swiftlint-warning-burndown.md`](12-swiftlint-warning-burndown.md).
Este prompt é só sobre tamanho de arquivo.

## Por que funciona

A pergunta que faz esse trabalho dar errado é sempre a mesma: *onde
cortar*. Um agente sem instrução corta onde a contagem de linhas manda —
tira 200 linhas do fim do `View`, joga num `Helpers.swift`, e o resultado
são dois arquivos que só fazem sentido lidos juntos.

Por isso o prompt define o corte por responsabilidade, não por linha, e
usa as mesmas quatro costuras do 09, em Swift: lógica de negócio vira
tipo de domínio, bloco de SwiftUI repetido vira `View` menor, acesso a
dados vira tipo de repositório, aglomerado de helpers vira módulo do
conceito. Se nenhuma costura existe, a instrução é dizer isso e parar.

O ritmo é o mesmo: **um arquivo por vez, um commit por arquivo**, com
`xcodebuild` (e testes, se existirem) entre cada um. Em Swift não existe
reexport de barrel tão barato quanto `export * from './foo'` — a
preservação de interface é manter o tipo público original no arquivo
original como fachada fina, não espalhar rename em todo o projeto.

## Como adaptar os placeholders

- **`[LINT_COMMAND]`** — em geral `./scripts/lint.sh`. Se o 10 não
  instalou o script, `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swiftlint lint`.
- **`[TEST_COMMAND]`** — o scheme de teste do Xcode, ou `none` se o
  projeto não tem target de teste.
- **`[TYPECHECK_COMMAND]`** — `xcodebuild -scheme … -destination … build`
  (ou `swift build` num pacote SPM). Nunca `none` num projeto Swift:
  o compilador *é* o typecheck.
- **`[MAX_LINES]`** — o teto. Padrão: `350`.
- **`[BATCH_SIZE]`** — comece com `3`.
- **`[RULE_ID]`** — se você instalou pelo prompt 10, é `file_length`.

## O prompt

```
Split the Swift files that exceed this project's per-file size budget
into smaller, focused types. This is behavior-preserving refactoring,
not a rewrite and not a feature change.

If this project is JavaScript or TypeScript, stop and use
09-file-size-refactor.md with RULE_ID=quality/max-lines.

## 0. Ground truth

Run [LINT_COMMAND] and list every file reported by [RULE_ID], with its
actual line count, sorted largest first. Use the real output from running
it now. Never a count from memory, from a previous message, or from a
summary.

If the list is empty, stop. Report "no files over budget" and do not
invent a split. That is a successful 10, not a failed 11.

Report the list before touching anything.

## 1. Pick the batch

Take the [BATCH_SIZE] largest files. Do not start on any others.

For each one, before editing, state:
  - what the file is responsible for today, in one sentence
  - the seams you found, and which one you will cut on
  - what its public types and members are (the names other files use)

## 2. Where to cut

Cut on responsibility, never on line count. The four seams worth looking
for, in this order:

  - business logic mixed into a SwiftUI View or UIViewController -> a
    domain type or use-case
  - a repeated SwiftUI block -> a reusable View
  - data access (SwiftData, GRDB, Core Data, URLSession bags) -> a
    repository or adapter
  - a cluster of helpers that only serve one concept -> a
    domain-specific type

If a file has no seam — it is one long, genuinely cohesive
implementation — say so, leave it alone, and move to the next file.
Report it as "no natural seam" and let a human decide.

Never split at an arbitrary line number. A file named Helpers.swift,
Utils.swift, Misc.swift or Common.swift holding whatever was left over
is a failure, not a result.

## 3. Preserve the interface

After the split, the original file's public types must still exist, with
the same names and the same signatures. Prefer leaving the original file
as a thin facade that owns the public type and delegates, over renaming
every call site.

Swift has no cheap `export * from`. Do not "clean up" by making every
importer point at the new file unless you say so explicitly before
doing it, and only when the original file is meant to disappear.

## 4. One file at a time

For each file in the batch, in order:

  a. make the split
  b. run [TYPECHECK_COMMAND]
  c. run [TEST_COMMAND] (skip if it is "none")
  d. run [LINT_COMMAND] and confirm the file is no longer reported, and
     that no NEW violation appeared anywhere
  e. commit, with a message naming the file and the seam you cut on
  f. only then move to the next file

If b, c, or d fails, fix it before moving on.

Watch for a specific trap in step d: extracting a View can push the new
file over the budget, and moving a helper can change Swift 6 isolation
or sendability and surface as a compiler error rather than a lint error.
Both are your problem, in the same commit.

Set DEVELOPER_DIR when running SwiftLint. A SourceKit crash is not a
clean lint.

## 5. Stop and report

After [BATCH_SIZE] files, stop. Do not continue into the next batch on
your own.

Report:
  - the files you split, and the seam used for each
  - the files you deliberately did NOT split, and why
  - the output of [LINT_COMMAND] run one final time: how many files are
    still over the budget, and their names
  - any violation of another rule that appeared as a side effect

Mark nothing as done that you did not verify by running the command again.

Codebase: [STACK/FRAMEWORK]. Budget: [MAX_LINES] lines. Rule: [RULE_ID].
```

## Exemplo de uso

Imagine que o prompt 10 reportou quatro arquivos acima de 350 linhas num
app SwiftUI, o maior um `LauncherView.swift` de 780 linhas. Você
preencheria:

- `[LINT_COMMAND]` → `./scripts/lint.sh`
- `[TEST_COMMAND]` → `none`
- `[TYPECHECK_COMMAND]` → `xcodebuild -scheme App -destination 'platform=macOS' build`
- `[MAX_LINES]` → `350`
- `[BATCH_SIZE]` → `3`
- `[RULE_ID]` → `file_length`

O agente lista os quatro de verdade, pega os três maiores, no
`LauncherView` reporta a costura "lista e campo de busca são Views
repetíveis", extrai, mantém `LauncherView` público, roda o build, roda o
lint, commita. Se o terceiro arquivo for um parser coeso de 400 linhas,
reporta "sem costura natural" e não mexe.

## Dicas

- `[BATCH_SIZE]` baixo mantém o diff no tamanho que um humano revisa.
- "Sem costura natural" às vezes está certo. O 10 não tem `ignore` por
  arquivo: a saída honesta é deixar reportado, ou um
  `// swiftlint:disable file_length` com o motivo, nunca subir o teto.
- Combine com [`03-multi-agent-code-review.md`](03-multi-agent-code-review.md)
  no fim de cada lote.
