# Neovim cheatsheet

Referencia de los atajos y comandos definidos por `~/Tools/nvim`.

> `mapleader` es `\\` (barra inversa). Las teclas sin modo indicado son de
> modo normal. `<C-x>` significa `Ctrl-x`, `<A-x>` significa `Alt-x` y
> `<CR>` significa Enter.

## Movimiento y edición

| Modo | Tecla | Acción |
| --- | --- | --- |
| `n` | `Q` | Ejecutar la macro `q` |
| `x` | `p` | Pegar conservando la selección visual |
| `i` | `jk` / `JK` | Volver a modo normal |
| `n`, `v` | `;` | Abrir la línea de comandos (`:`) |
| `n`, `v` | `-` | Buscar (`/`) |
| `n` | `H` / `L` | Ir al inicio (`^`) / final (`$`) de la línea |
| `n` | `<C-h/j/k/l>` | Moverse a la ventana izquierda/inferior/superior/derecha |

## Splits, pestañas y terminal

| Tecla | Acción |
| --- | --- |
| `<leader>v` | `:vsplit` |
| `<leader>s` | `:split` |
| `<leader>t` | `:tabnew` |
| `<leader>c` | `:tabclose` |
| `<leader>[` / `<leader>]` | Pestaña anterior / siguiente |
| `<C-m>` | Abrir/cerrar terminal inferior de 10 líneas |
| `jk` en terminal | Salir del modo terminal |

## Diagnósticos, números y spellcheck

| Tecla | Acción |
| --- | --- |
| `<F1>` | Diagnóstico flotante bajo el cursor |
| `<F2>` | Alternar números absolutos y relativos |
| `<F3>` | Alternar números relativos |
| `<F6>` | Alternar spellcheck en inglés (`en_us`) |
| `<F7>` | Seleccionar spellcheck en español (`es`) |
| `<leader>us` | Alternar spellcheck con Snacks |
| `<leader>uw` | Alternar wrap con Snacks |
| `<leader>uL` | Alternar números relativos con Snacks |
| `<leader>uc` | Alternar `conceallevel` |
| `<leader>uh` | Alternar inlay hints |
| `<leader>ug` | Alternar indent guides |
| `<leader>uD` | Alternar modo dim |

## Telescope

| Tecla | Comando | Acción |
| --- | --- | --- |
| `<leader>ff` | `:Telescope find_files` | Buscar archivos |
| `<leader>fg` | `:Telescope live_grep` | Buscar texto con ripgrep |
| `<leader>fb` | `:Telescope buffers` | Listar buffers |
| `<leader>fh` | `:Telescope help_tags` | Buscar en la ayuda |

También están disponibles `:Telescope find_files`, `:Telescope live_grep`,
`:Telescope buffers` y `:Telescope help_tags` directamente.

## Neo-tree, wiki y Snacks

| Tecla | Acción |
| --- | --- |
| `<C-n>` | `:Neotree toggle` |
| `<leader>ww` | Abrir wiki |
| `<leader>wf` | Abrir wiki en ventana flotante |
| `<leader>wt` | Abrir wiki en pestaña nueva |
| `<leader>z` | Zen mode |
| `<leader>Z` | Zoom |
| `<leader>.` | Scratch buffer |
| `<leader>S` | Seleccionar scratch buffer |
| `<leader>n` | Historial de notificaciones |
| `<leader>r` | Renombrar archivo |
| `<leader>N` | Novedades de Neovim |

Rutas configuradas en Neowiki:

```text
Notes      ~/Notes/
Codes      ~/Codes/
Exercices  ~/Exercices/
```

Funciones de depuración disponibles después de cargar Snacks:

```vim
:lua dd(valor)   " Snacks.debug.inspect
:lua bt()        " backtrace
```

## Escritura y plugins de edición

| Tecla / comando | Acción |
| --- | --- |
| `s` en `n`, `x`, `o` | Saltar con Flash |
| `:Goyo` / `:Goyo!` | Entrar / salir del modo de escritura centrado |
| `:Lazy` | Abrir el gestor de plugins |
| `:Lazy sync` | Sincronizar plugins con `lazy-lock.json` |
| `:TSUpdate` | Actualizar parsers de Treesitter |
| `:TSInstall <parser>` | Instalar un parser |

Además están activos `nvim-surround`, `mini.pairs`, `indent-blankline`,
`gitsigns` y `nvim-colorizer`, con sus mappings estándar de plugin.

## Completion y snippets

| Modo | Tecla | Acción |
| --- | --- | --- |
| `i` | `<Tab>` | Confirmar la sugerencia seleccionada |
| `i` | `<C-j>` / `<C-k>` | Siguiente / anterior sugerencia |
| `i`, `s` | `<A-k>` | Expandir snippet o saltar al siguiente campo |
| `i`, `s` | `<A-j>` | Saltar al campo anterior |
| cualquiera | `sign` | Insertar `Román García Guill` |

Comando personalizado:

```vim
:ListSnippets
```

Muestra los snippets del `filetype` actual. Los snippets propios están en
`lua/snippets/python.lua`, `lua/snippets/sh.lua` y `lua/snippets/typst.lua`.

## LSP y Mason

Servidores configurados:

```text
lua_ls    Lua
pyright   Python
clangd    C/C++
texlab    LaTeX
marksman  Markdown
bashls    Bash
fortls    Fortran
```

Comandos útiles:

```vim
:Mason
:LspInfo
:LspStart <servidor>
:LspStop <servidor>
:LspRestart <servidor>
:lua vim.diagnostic.setqflist()
:lua vim.lsp.buf.hover()
:lua vim.lsp.buf.definition()
:lua vim.lsp.buf.implementation()
:lua vim.lsp.buf.references()
:lua vim.lsp.buf.rename()
:lua vim.lsp.buf.code_action()
:lua vim.lsp.buf.format()
```

`<F1>` muestra el diagnóstico de la posición actual. Los comandos LSP
requieren que el servidor correspondiente esté instalado y activo.

## Markdown

Al abrir Markdown se cargan Treesitter (`markdown` y `markdown_inline`),
`render-markdown.nvim` y `nvim-web-devicons`.

```vim
:TSInstall markdown markdown_inline
:TSUpdate markdown markdown_inline
:RenderMarkdown toggle
:RenderMarkdown enable
:RenderMarkdown disable
```

Los tres últimos comandos pertenecen a `render-markdown.nvim`; si una versión
del plugin no los expone, ejecutar `:RenderMarkdown` para ver su interfaz.
Los símbolos dependen también de la fuente del terminal y sus glifos.

## Typst

Solo para buffers `typst`:

| Tecla | Acción |
| --- | --- |
| `<leader>lw` | Ejecutar `typst watch %` en segundo plano |
| `<leader>ll` | Alternar `:TypstPreviewToggle` |

Comandos equivalentes:

```vim
:TypstPreviewToggle
:silent !typst watch % &
```

## Ejecución con `<F5>`

`<F5>` guarda el buffer y ejecuta según el `filetype`:

| Filetype | Acción |
| --- | --- |
| `python` | Split y `python3 %` |
| `sh`, `bash` | Split y `bash %` |
| `gnuplot` | `gnuplot %` |

Los programas externos deben existir en `$PATH`.

## Automatismos

| Evento | Archivo / tipo | Acción |
| --- | --- | --- |
| `BufNewFile` | `*.py` salvo `test_*.py` | Cabecera Python y `main()` |
| `BufNewFile` | `test_*.py` | Esqueleto de test con pytest |
| `BufNewFile` | `*.sh` | Cabecera Bash |
| `BufWritePost` | `*.py` | Ejecutar `black %` |
| `BufWritePost` | `*.sh` | Ejecutar `shellcheck %` |
| `FocusGained`, `BufEnter` | cualquier buffer | Ejecutar `:checktime` |
| `BufReadPost` | cualquier buffer | Restaurar posición del cursor |
| `FileType` | Python, shell y Bash | Resaltar líneas `# %%` |

Los hooks de guardado requieren `black` y `shellcheck`. Para lanzarlos a mano:

```vim
:silent !black %
:silent !shellcheck %
```

## Dashboard de Alpha

| Tecla | Acción |
| --- | --- |
| `w` | Abrir `~/Notes/` |
| `n` | Crear buffer nuevo |
| `f` | Buscar archivo con Telescope |
| `q` | Salir de Neovim |

## Iron REPL

`iron.nvim` está incluido, pero el bloque actual no configura mappings ni
comandos propios: solo contiene un comentario pendiente. No hay que asumir
atajos de Iron hasta completar esa configuración.

## Opciones principales

```text
shell          $SHELL o /bin/sh
clipboard      unnamedplus
tabstop        4
shiftwidth     4
colorcolumn    80
wrap           activado
linebreak      activado
number         activado
relativenumber desactivado inicialmente
mouse          activado
scrolloff      8
timeoutlen     200 ms
updatetime     250 ms
background     dark
```

## Diagnóstico rápido

```vim
:checkhealth
:Lazy
:Lazy sync
:Mason
:LspInfo
:TSInstallInfo
:set filetype?
:set runtimepath?
:scriptnames
:verbose nmap <C-m>
:verbose nmap <leader>ff
:verbose imap <Tab>
```

`:verbose map` indica también el archivo que creó el mapping, útil cuando dos
plugins compiten por la misma combinación.

## Auditoría de conflictos

No hay dos mappings registrados para la misma combinación y el mismo modo.
Estas combinaciones parecen repetidas, pero están separadas correctamente:

| Combinación | Modos | Resultado |
| --- | --- | --- |
| `<C-j>` / `<C-k>` | normal / inserción | Navegar ventanas en normal; cambiar sugerencia en completion |
| `jk` | inserción / terminal | Salir de inserción; salir del modo terminal |
| `<F5>` | buffer local | Ejecutar Python, Bash o gnuplot según `filetype` |
| `<Tab>` | inserción | Confirmar completion; no cambia el modo normal |
| `<C-r>` | todos | No está remapeado; conserva el comportamiento estándar |
| `<C-b>` | normal | No está ocupado por esta configuración; queda libre para tmux |

`<F2>` alterna números absolutos y relativos, mientras que `<F3>` alterna
solo los relativos. Es una pequeña redundancia intencionada, no un conflicto.
