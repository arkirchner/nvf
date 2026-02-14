# Agent Guide for nvf

This file is for automated coding agents. Follow repository conventions and
documented workflows. When unsure, read the manual sections referenced in
`docs/manual/hacking.md`.

## Quick Facts

- Primary language: Nix (plus Markdown docs, some Lua snippets embedded).
- This is a Nix flake; most actions are `nix` commands.
- Formatting is enforced in CI for Nix and Markdown.
- No Cursor or Copilot rules are present in this repo.

## Build, Lint, Test

There is no single unit-test runner. Validation is done via Nix flake checks
and building packages/docs. Use the commands below.

### One-time setup

```bash
# Enter dev shell with formatter/linter tools
nix develop
```

### Build

```bash
# Build default package (minimal config)
nix build .#nix

# Build maximal demo package
nix build .#maximal
```

### Run (manual testing)

```bash
# Run the dev configuration (edit flake/develop.nix locally)
nix run .#develop
```

### Lint / Static checks

```bash
# Flake checks (includes formatting checks)
nix flake check

# Nix formatting check (treewide)
nix run nixpkgs#alejandra -- --check . --exclude npins

# Markdown formatting check
nix run nixpkgs#deno -- fmt --check --ext md **/*.md

# Nix formatter (treewide for both Nix + Markdown via wrapper)
nix fmt
```

### Documentation builds

```bash
# Build the HTML manual (required if docs change)
nix build .#docs-html

# Link checker (optional but recommended when adding links)
nix build .#docs-linkcheck
```

### Editorconfig conformance

Editorconfig is enforced in CI. Make sure your editor respects `.editorconfig`.

### Running a single test

There is no single-test runner. Use one of these targeted checks instead:

- `nix build .#checks.<system>.nix-fmt` for Nix formatting only.
- `nix build .#checks.<system>.md-fmt` for Markdown formatting only.
- `nix build .#docs-html` for docs generation only.

Replace `<system>` with your system, e.g. `x86_64-linux`.

## Code Style

Authoritative guidance is in `docs/manual/hacking.md` and `.editorconfig`.

### Treewide

- File names: prefer kebab-case.
- Text files: keep to ~80 columns (esp. Markdown and Nix strings).
- Respect `.editorconfig` (tabs for most files, spaces for Markdown/Nix/YAML).

### Nix formatting

- Use Alejandra for all Nix formatting.
- Use `nix fmt` to format the tree (Nix + Markdown wrapper).
- Keep merges inline when the right side is a single line:
  `mkEnableOption "desc" // { default = true; }`.
- If the right-hand side spans multiple lines, it is fine to break it.
- Lists: unfold when there are multiple items or comments.

### Markdown formatting

- Format with `deno fmt` (`deno fmt --ext md **/*.md`).
- Markdown uses a Nixpkgs-flavored CommonMark variant; keep to 80 columns.

### Imports and structure (Nix)

- Prefer `let ... in` and `inherit` for clarity; keep `inherit` grouped.
- Use `mkIf`, `optional`, `optionalString` for conditional config.
- Group top-level arguments consistently: `{config, lib, options, ...}`.
- Keep module wiring predictable: `config = mkIf cfg.enable { ... }`.

### Types and options

- Use `mkOption`/`mkEnableOption` with types from `lib.types`.
- Order `mkOption` fields: `type` → `default` → `example` → `description`.
- Keep option descriptions concise and within ~80 columns.

### Naming conventions

- Files: kebab-case.
- Nix module attributes: camelCase unless the module naming already uses
  kebab-case (e.g., plugin identifiers).
- Modules prefer explicit `cfg = config.<path>` and `cfg.<field>` usage.

### Error handling and warnings

- Use `lib.warn` for deprecations or compatibility warnings.
- Guard optional behaviors with feature flags (`mkIf cfg.enable`).
- Prefer `optionalString`/`optional` for conditional Lua/Nix emission.

### Lua snippets

- Lua is typically embedded via `lib.generators.mkLuaInline` or
  `lib.nvim.lua.toLuaObject`.
- Keep Lua snippets minimal and deterministic; avoid side effects unless needed.

## Documentation and changelog expectations

- Most changes require documentation updates.
- Always update release notes for user-facing changes.
- If you add links, run `nix build .#docs-linkcheck`.

## Development notes

- `flake/develop.nix` is for local testing only; do not commit edits there.
- `configuration.nix` is a demo configuration; only change it for demo updates.

## Commit message style (if you are asked to commit)

- Conventional Commits are not used here.
- Prefer `component: description` with an optional long description.
- Keep commits self-contained; do not rely on later commits for fixes.

## References

- `docs/manual/hacking.md`
- `.editorconfig`
- `.github/workflows/check.yml`
