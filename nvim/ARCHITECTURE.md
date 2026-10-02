# Neovim configuration architecture

This directory is the canonical configuration. On each computer, the intended
installation is:

```sh
ln -sfn "$HOME/Tools/nvim" "$HOME/.config/nvim"
```

Do not edit a second copy under `~/.config/nvim`; that path should resolve to
this directory.

## Layers

- `init.lua`: loads options, keymaps, autocmds, terminal helpers and Lazy.
- `lua/config/`: editor policy independent of plugins.
  - `options.lua`: defaults, shell, indentation, search and display.
  - `keymaps.lua`: global mappings and toggles.
  - `autocmds.lua`: cursor restore, format/check hooks, notebook cells,
    language templates and F5 execution.
  - `terminal.lua`: one split terminal toggled with `<C-b>`.
  - `lazy.lua`: bootstraps `lazy.nvim` and imports `lua/plugins/`; the shared
    `Tools` baseline intentionally loads plugin specs eagerly.
- `lua/plugins/`: one focused Lazy specification per concern.
  - `ui.lua`: dashboard, file tree, theme, colourizer and Markdown rendering.
  - `writing.lua`: Goyo, surrounding, pairs, jump/navigation helpers.
  - `treesitter.lua`: syntax trees and Markdown parsers.
  - `lsp.lua`: Mason plus Lua, Python, C/C++, TeX, Markdown, Bash and Fortran.
  - `completition.lua` and `snippets.lua`: completion and LuaSnip.
  - `telescope.lua`: file, grep, buffer and help search.
  - `git.lua`: Gitsigns.
  - `interactive.lua`: Iron REPL and optional wiki/scratch integrations.
  - `typst.lua`: Typst preview/watch commands.
- `lua/snippets/`: personal snippets loaded by LuaSnip.
- `lazy-lock.json`: reproducible plugin revisions; update deliberately.

## Local copy versus `Tools/nvim`

The local copy had the cleaner minimal baseline: zsh as the shell, the dark
`zaibatsu` theme, a larger terminal split, a working Fortran LSP entry and no
unused dashboard extras. The `Tools` copy had the broader plugin set, including
Treesitter, Neo-tree, colourizer, Flash, indent guides, surround, mini.pairs,
wiki and Snacks. The merged configuration keeps the useful core and makes
optional functionality lazy where possible.

The old `Tools` copy also had two defects: `cell_group` was referenced before
being defined, and `theme.current` was optional but reported an error when
absent. Both are fixed by defining the autocmd group and making the theme
loader fall back quietly. The active colour scheme remains selected by the
shared theme fallback, with `theme.current` available as a per-machine
override.

## Markdown rendering

`render-markdown.nvim` needs Treesitter's `markdown` and `markdown_inline`
parsers. Its heading glyphs also depend on the terminal font containing the
chosen Unicode/Nerd Font symbols; installing the plugin alone cannot provide
those glyphs. The font archive plan is documented below and is intentionally
separate from the Neovim plugin lockfile.

## Font archive

Keep installable archives in `~/Templates/fonts/`:

- `CommitMonoV143.zip` (already present under `~/Templates/`).
- An archive of the installed Iosevka family, or the upstream Iosevka Nerd
  Font archive if patched glyphs are required by the terminal.

Installation on a new machine should unpack an archive into a user font
directory, run `fc-cache -f`, then restart the terminal. Verify with:

```sh
fc-match 'Iosevka Term'
fc-match 'CommitMono'
```

The Markdown heading symbols are not a reliable test of an ordinary Iosevka
build: use a Nerd Font build or configure `render-markdown` with glyphs
available in the chosen font.

## Notes and Bitacora

`Tools/bin/notes` already opened new notes under `~/Notes/Bitacora`, but
`Tools/bin/session start` used `touch ~/Notes/YYYY-MM-DD.md`. That was the
source of the empty root-level files. `session` now reports the intended
Bitacora path without creating it, and `notes` only creates a file when Neovim
actually saves it. Existing empty root files are left untouched for manual
review.

Suggested cleanup, after checking each file is disposable:

```sh
find "$HOME/Notes" -maxdepth 1 -type f -name '*.md' -size 0 -print
```

## Session workflow proposal

The current `session end` stages and commits every configured repository. That
is risky for unrelated work, and requiring start/end on every computer is
friction. A better next step is a small explicit `session sync` command that:

1. discovers repositories below a configured set of roots;
2. reports clean, changed, ahead, behind and divergent states;
3. pulls only clean repositories with fast-forward-only;
4. never commits or pushes implicitly;
5. offers an explicit repository-scoped `session sync --push REPO`.

For automatic context, shell hooks can record the current repository and
timestamps on `cd`/shell exit, but they should write an append-only local log,
not modify Git history. This keeps synchronization deliberate while removing
the ritual of manually starting and ending a session.

## To-do candidates

From `~/Notes/ToDo.md`, the most directly relevant additions are `jet.nvim`,
the `awesome-neovim` catalogue and grammar correction. They are deliberately
not installed automatically: `jet.nvim` and grammar tools add external
dependencies and should be evaluated one at a time after the core config is
stable.
