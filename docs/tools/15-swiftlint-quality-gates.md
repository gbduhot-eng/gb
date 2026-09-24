# Quality Gates de Lint: SwiftLint

Este é o trilho Swift do mesmo raciocínio de
[`06-eslint-biome-quality-gates.md`](06-eslint-biome-quality-gates.md) —
aviso vira erro como migração rastreada, teto de arquivo é gate, e o
agente **copia** a regra em vez de escrevê-la. Não substitui o 06: se o
projeto é JavaScript ou TypeScript, fique no 06 e nos prompts 08 → 09 →
02.

Aqui o linter é um só. SwiftLint no modo `only_rules` com duas regras:
`file_length` (teto, padrão 350) e `no_direct_print` (`print` /
`debugPrint` / `dump` / `NSLog`). O preset recommended do SwiftLint é o
equivalente a ligar o `eslint:recommended` inteiro — estilo, não gate.
O template em [`templates/swiftlint/`](../../templates/swiftlint/)
apaga esse ruído de propósito.

## A sequência (igual 08 → 09 → 02)

1. **Instalar e medir** —
   [`../prompts/10-swiftlint-quality-gates-install.md`](../prompts/10-swiftlint-quality-gates-install.md)
2. **Quebrar os arquivos grandes** —
   [`../prompts/11-swift-file-size-refactor.md`](../prompts/11-swift-file-size-refactor.md)
   (se a lista do passo 1 for vazia, este passo não roda)
3. **Zerar o resto** —
   [`../prompts/12-swiftlint-warning-burndown.md`](../prompts/12-swiftlint-warning-burndown.md)
   (se as duas regras já nasceram em `error` com zero violações, este
   passo para no ground truth)

Cole no agente, um de cada vez:

```
Leia https://raw.githubusercontent.com/soumatheusgomes/vibe-coding-toolkit/main/docs/prompts/10-swiftlint-quality-gates-install.md
e execute o prompt que está nesse arquivo neste projeto. Use MAX_LINES=350.
```

```
Leia https://raw.githubusercontent.com/soumatheusgomes/vibe-coding-toolkit/main/docs/prompts/11-swift-file-size-refactor.md
e execute o prompt que está nesse arquivo neste projeto. Use MAX_LINES=350,
BATCH_SIZE=3 e RULE_ID=file_length. Descubra sozinho os comandos de lint,
teste e typecheck lendo o xcodeproj, o Package.swift e scripts/lint.sh.
```

```
Leia https://raw.githubusercontent.com/soumatheusgomes/vibe-coding-toolkit/main/docs/prompts/12-swiftlint-warning-burndown.md
e execute o prompt que está nesse arquivo neste projeto, para o conjunto
inteiro de avisos restantes. Descubra sozinho os comandos de lint, teste,
typecheck e build lendo o xcodeproj, o Package.swift e scripts/lint.sh.
```

## O que muda em relação ao ESLint

| ESLint (08) | SwiftLint (10) |
|---|---|
| `quality/max-lines` | `file_length` |
| `quality/no-direct-console` | `no_direct_print` (custom_rules) |
| `quality/no-direct-data-access` | só se existir ORM; senão, pular |
| `npm run lint` | `./scripts/lint.sh` |
| `tsc` / `lint:types` | `xcodebuild` (o compilador *é* o typecheck) |
| `ignore` por arquivo na regra | não existe; ofensor fica reportado ou ganha `swiftlint:disable` visível |
| `package.json` | `xcodeproj` / `Package.swift` |

Duas pegadinhas que não existem no trilho ESLint:

- **`DEVELOPER_DIR`**. SwiftLint recente carrega SourceKit do Xcode. Sem
  `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` no Tahoe /
  Xcode 26, o processo aborta em `sourcekitdInProc` e a contagem vira
  zero por acidente.
- **Não pendure o lint no `xcodebuild`.** O 08 também não mistura
  `eslint .` com o compilador. Plugin SPM / Run Script no pbxproj é
  opcional e fácil de quebrar na mão; o gate é o script.

A fronteira de banco, quando o app não tem banco, **não se inventa**. O
08 já manda remover `no-direct-data-access` nesse caso; o 10 faz o
mesmo.
