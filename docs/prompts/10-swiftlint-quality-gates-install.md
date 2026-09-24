# Instalar os quality gates de SwiftLint (teto de 350 linhas)

## Atalho: só o link

Este é o irmão Swift do
[`08-eslint-quality-gates-install.md`](08-eslint-quality-gates-install.md).
Mesma sequência — instalar, medir, não consertar. Cole no agente:

```
Leia https://raw.githubusercontent.com/soumatheusgomes/vibe-coding-toolkit/main/docs/prompts/10-swiftlint-quality-gates-install.md
e execute o prompt que está nesse arquivo neste projeto. Use MAX_LINES=350.
```

O resto deste documento é o mesmo prompt, aberto.

## Quando usar

Use este prompt quando o projeto é **Swift** (app iOS/macOS, SPM, Xcode)
e você quer as duas regras que o toolkit defende nesse mundo — teto de
tamanho por arquivo e proibição de `print` / `NSLog` direto — já
funcionando, sem o agente inventar um guia de estilo SwiftLint.

Se o projeto é JavaScript ou TypeScript, **pare e use o 08**. Este
arquivo não instala ESLint, não cria `package.json` e não copia os
`.cjs` de `templates/eslint/`.

A diferença pro SwiftLint "recommended" é a mesma do 08 pro preset do
ESLint: o agente não liga o pacote inteiro. Ele copia um YAML com
`only_rules` e adapta caminhos. Ligar colon-spacing e trailing_whitespace
junto com o teto de 350 linhas é o jeito mais rápido de o time desligar
o linter na sexta.

Depois de instalar, o passo natural é
[`11-swift-file-size-refactor.md`](11-swift-file-size-refactor.md) — é
ele que manda o agente quebrar os arquivos que estouraram o teto. Se a
medição voltar zero ofensores, o 11 para no passo 0; não inventa fila.

## Por que funciona

A parte difícil de uma regra de lint caseira não é a ideia, é o código.
Uma `custom_rule` escrita na hora erra em silêncio: pega `print` dentro
de comentário, esquece `debugPrint`, ou depende de SourceKit e cai no
Xcode 26 sem `DEVELOPER_DIR`. Nenhum desses erros aparece como falha —
aparece como uma regra que "não pega nada", e a pessoa desliga.

Por isso o prompt não pede pro agente escrever o YAML. Ele pede pra
copiar. O que o agente decide é só o que realmente depende do seu
projeto: qual pasta é a fonte, se existe adaptador de log, se existe
cliente de banco (quase sempre não, em app nativo local), quais
diretórios ignorar.

E o passo final é medir, não consertar. Regra com zero violação nasce em
`error`; regra com violação nasce em `warn` com a contagem anotada como
linha de base. Um gate que nasce vermelho em cima de código que já
existia não é gate, é ruído.

## Como adaptar os placeholders

- **`[MAX_LINES]`** — o teto de linhas por arquivo. O padrão do toolkit
  é `350`. Abaixo de ~200 a regra vira briga constante em código
  legítimo; acima de ~500 ela para de exercer pressão.
- **`[SOURCE_URL]`** — de onde o agente pega os arquivos. Se você clonou
  este repositório, use o caminho local `templates/swiftlint`. Se não,
  use a URL raw do GitHub que já está preenchida no prompt.

## O prompt

```
Install this project's SwiftLint quality gates by COPYING the pre-written
config, not by writing rules from scratch. The YAML already exists and is
already tested; your job is to place it and adapt the paths to this
project's real shape.

## 0. Get the files

Fetch these three files from [SOURCE_URL] (default:
https://raw.githubusercontent.com/soumatheusgomes/vibe-coding-toolkit/main/templates/swiftlint):

  swiftlint.yml.example
  lint.sh
  verify.sh

Place them in the project like this:

  ./.swiftlint.yml             (from swiftlint.yml.example)
  ./scripts/lint.sh            (from lint.sh)
  ./verify.sh                  (temporary; delete after step 5)

Copy swiftlint.yml.example and lint.sh byte for byte first. Do not
reformat them, do not convert the custom_rules to a Swift plugin, do not
merge extra SwiftLint style rules "while you're here". If you rewrite
them, this prompt has failed.

## 1. Read the project before changing anything

Report what you found before continuing:

- whether this is Swift (xcodeproj, Package.swift, .swift files)
- existing lint script, existing SwiftLint version if any
- the source root: Sources/, AppName/, or the repository root
- the presentation layer: SwiftUI views, UIKit view controllers
- the data module: which type is the database/ORM client, if any
- the log adapter: the module the project already logs through, if any
  (os.Logger, a wrapper around it — not print)

If this project is JavaScript or TypeScript and has no Swift sources,
stop. Point to 08-eslint-quality-gates-install.md. Do not create
package.json, do not install eslint.

If there is no data module, say so and do not invent a
no_direct_data_access custom rule. A boundary this project does not have
is noise.

## 2. Install SwiftLint

  brew install swiftlint

Do not add a SwiftLint SPM build-tool plugin or a Run Script build phase
unless the project already has one. The gate is a separate command, the
same way "eslint ." is not the TypeScript compiler. Hand-editing pbxproj
to attach a plugin is a silent-failure mode.

On Apple Silicon / recent Xcode, SwiftLint needs SourceKit from Xcode,
not from a random toolchain:

  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

lint.sh already exports that. If you run swiftlint by hand, set it.

## 3. Adapt .swiftlint.yml

Every item here is a real edit against what step 1 found, not a review:

- included: the real source root (drop Sources/ if the app folder has
  another name)
- excluded: this project's build output (DerivedData, .build, Pods)
- file_length warning and error: set both to [MAX_LINES] for now —
  step 6 may drop error after measuring
- custom_rules.no_direct_print.excluded: the real log adapter path, or
  delete the commented excluded block if there is none
- do not add opt_in_rules, identifier_name, line_length, or any
  framework preset. only_rules stays as the two gates

SwiftLint has no per-rule ignore list like ESLint's quality/max-lines
ignore option. Do not invent a YAML key SwiftLint will silently skip.
Generated files go in excluded. Cohesive files over budget stay reported
until 11 or a human puts them on an explicit swiftlint:disable with a
reason.

## 4. Wire the command

  scripts/lint.sh

chmod +x. Document it next to the existing build command (README, not a
verify-*.sh the project already said does not exist). Do not add lint to
xcodebuild.

## 5. Verify the copy survived

  sh verify.sh

Expected: three lines ending in ": ok", exit code 0. Anything else means
the copy is broken — fix it before going further. Delete verify.sh
afterwards, or keep it and wire it into tests; do not leave it lying
around unexplained.

## 6. Run the linter and MEASURE

  ./scripts/lint.sh

Report the count per rule. Then set severities from the count, not from
preference:

- zero violations for a rule: leave it at error (file_length: warning
  and error both [MAX_LINES]; no_direct_print severity: error)
- violations exist: drop that rule to warning and write the count in a
  comment next to it. For file_length, keep warning at [MAX_LINES] and
  remove the error key. That count is the baseline
- file_length with only a handful of offenders: keep error at [MAX_LINES]
  and leave those files reported. A short list in the report beats a
  rule nobody trusts. Do not raise [MAX_LINES]

If SwiftLint crashes loading sourcekitdInProc, you forgot DEVELOPER_DIR.
Fix the environment; do not delete match_kinds to "make it pass".

## 7. Report

State: which rules were installed, which were skipped and why, the
violation count per rule, which rules are at warning with a baseline,
the list of files over the [MAX_LINES]-line budget sorted by size, and
the exact commands to run the linter.

If the over-budget list is empty, say so. Prompt 11 then has nothing to
do; that is a valid outcome, not a failed install.

## Rules for you, the agent

Do NOT fix any violation you found. Installing the gate and measuring
what it catches is the entire job. Refactoring is separate work with its
own review.

Do NOT raise [MAX_LINES] to make a file pass. The budget is the point.

Do NOT enable SwiftLint's default style rules because they exist.
only_rules is the point.

Do NOT install Node, ESLint, or a package.json in a Swift project.
```

## Exemplo de uso

Imagine um launcher nativo de macOS em Swift 6, pasta de fonte `App/`,
sem banco, sem adaptador de log, oito arquivos `.swift`, o maior com 192
linhas. Você preencheria:

- `[MAX_LINES]` → `350`
- `[SOURCE_URL]` → a URL raw padrão, já preenchida no prompt

O agente vê que não há `package.json`, copia os três arquivos, aponta
`included` pra `App/`, apaga a isenção de log, não inventa fronteira de
banco, roda `sh verify.sh` (três `ok`), roda o lint e volta: 
`file_length` zero violações, fica em `error`; `no_direct_print` zero
violações, fica em `error`; lista de arquivos acima de 350 vazia. E
para por aí — não conserta nada, não dispara o 11.

Se a lista não for vazia, ela é a entrada do
[`11-swift-file-size-refactor.md`](11-swift-file-size-refactor.md).

## Dicas

- Se o agente reescrever o YAML em vez de copiar, mande refazer. O ponto
  inteiro do prompt é que essas duas regras sejam sempre o mesmo código.
- Rode `sh verify.sh` antes de acreditar em qualquer contagem. Se o
  YAML chegou sem `only_rules`, um lint "limpo" não quer dizer nada —
  você está rodando o guia de estilo inteiro.
- `DEVELOPER_DIR` não é pedantismo. Sem ele, SwiftLint 0.65+ no Xcode 26
  aborta no SourceKit e a contagem vira zero por acidente.
- O raciocínio (aviso vira erro, fronteira mora no lint) é o mesmo de
  [`../tools/06-eslint-biome-quality-gates.md`](../tools/06-eslint-biome-quality-gates.md).
  O trilho Swift está em
  [`../tools/15-swiftlint-quality-gates.md`](../tools/15-swiftlint-quality-gates.md).
