" flist.vim maps for Vim
"  Author  : Charles E. Campbell, Jr.
" Copyright: Charles E. Campbell, Jr.
" License  : refer to the <Copyright> file for flist
"
if !exists("g:loaded_flistmaps_vim")
  let g:loaded_flistmaps_vim = 1

  " Make various lists of C/C++ functions
  "  \p? prototypes : \[px]g: globals   \pc: comment   \pp: all prototypes
  "  \x? externs    : \[px]s: statics                  \xx: all externs
  nnoremap \pc   :w<CR>:!${CECCMD}/flist -c  % >tmp.vim<CR>:r tmp.vim<CR>:!rm tmp.vim<CR>
  nnoremap \pg   :w<CR>:!${CECCMD}/flist -pg % >tmp.vim<CR>:r tmp.vim<CR>:!rm tmp.vim<CR>
  nnoremap \pp   :w<CR>:!${CECCMD}/flist -p  % >tmp.vim<CR>:r tmp.vim<CR>:!rm tmp.vim<CR>
  nnoremap \ps   :w<CR>:!${CECCMD}/flist -ps % >tmp.vim<CR>:r tmp.vim<CR>:!rm tmp.vim<CR>
  nnoremap \xg   :w<CR>:!${CECCMD}/flist -xg % >tmp.vim<CR>:r tmp.vim<CR>:!rm tmp.vim<CR>
  nnoremap \xs   :w<CR>:!${CECCMD}/flist -xs % >tmp.vim<CR>:r tmp.vim<CR>:!rm tmp.vim<CR>
  nnoremap \xx   :w<CR>:!${CECCMD}/flist -x  % >tmp.vim<CR>:r tmp.vim<CR>:!rm tmp.vim<CR>
endif
