"=============================================================================
" File:         ftplugin/c/previewWord.vim
" Author:       Georgi Slavchev <EMAIL:goyko@gbg.bg>
"               From <URL:http://vim.sf.net>
"               Adapted by Luc Hermitte <EMAIL:hermitte at free.fr>
"               <URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.0
let s:k_version = '2.2.0'
" Created:      ?
" Last Update:  15th Feb 2017
"------------------------------------------------------------------------
" Description:  «description» {{{
" Have you ever tried to call a function which parameters you have forgotten?
" Especially those long named and with long parameter list GTK+ functions like
" gtk_menu_item_image_from_stock_new(..........) !!!
" By accident I saw a function in Vim help. It's name was PreviewWord and it
" allowed one to jump in the preview window to the tag for the word cursor is
" on.
" I _slightly_ modified this function not to need tags file, but to search
" included files instead.  I wrote another function, which uses the above said
" one, which triggers PreviewWord when you open the parenthesis after a
" function name.
" }}}
"------------------------------------------------------------------------
" Installation: See |lh-cpp-readme.txt|
"=============================================================================
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_previewWord")
      \ && (b:loaded_ftplug_previewWord >= s:k_version)
      \ && !exists('g:force_reload_ftplug_previewWord'))
  finish
endif
let b:loaded_ftplug_previewWord = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

" Settings {{{2
setlocal previewheight=4

"------------------------------------------------------------------------
" Mappings {{{2
inoremap <buffer> <Plug>PreviewWord <C-o>:call <sid>PreviewWord()<CR>
nnoremap <buffer> <Plug>PreviewWord :call <sid>PreviewWord()<CR>
call lh#mapping#plug({'lhs': '<localleader>pw', 'rhs': '<Plug>PreviewWord', 'buffer':1}, 'in')

inoremap <buffer> <Plug>ClosePreviewWindow <C-o>:call <sid>ClosePreviewWindow()<CR>
nnoremap <buffer> <Plug>ClosePreviewWindow :call <sid>ClosePreviewWindow()<CR>
call lh#mapping#plug({'lhs': '<localleader>cpw', 'rhs': '<Plug>ClosePreviewWindow', 'buffer':1}, 'in')

" I've (LH) desactivated the '(' key because I use a bracketing system.
" inoremap <buffer> <c-space> <C-R>=<sid>PreviewFunctionSignature()<CR>

" g:preview_if_hold {{{2
let g:preview_if_hold = get(g:, 'preview_if_hold', 0)
let s:toggle_menu = {
      \ 'variable': 'preview_if_hold',
      \ 'values': [0, 1],
      \ 'texts': [ "No", "Yes" ],
      \ 'menu': {'priority': '50.10', 'name': 'C++.preview_if_hold'}
      \}
call lh#menu#def_toggle_item(s:toggle_menu)
nnoremap <Plug>TogglePreviewIfHold :Toggle Cpreview_if_hold<cr>
call lh#mapping#plug({'lhs': '<localleader>tpw', 'rhs': '<Plug>TogglePreviewIfHold'}, 'n')

" autocommands {{{2
augroup PreviewWord
  au!
  au! CursorHold *.[ch] nested :call <sid>DoPreviewWord()
augroup END
"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_previewWord")
      \ && (g:loaded_ftplug_previewWord >= s:k_version)
      \ && !exists('g:force_reload_ftplug_previewWord'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_previewWord = s:k_version
" Avoid global reinclusion
"------------------------------------------------------------------------
" Functions {{{2
"------------------------------------------------------------------------
" s:ClosePreviewWindow() {{{3
function! s:ClosePreviewWindow() abort
  silent! wincmd P " jump to preview window
  if &previewwindow " if we really get there...
    silent wincmd c " close the window
  endif
endfunction
"------------------------------------------------------------------------
" s:PreviewWord() {{{3
" Note:
" This is literally stolen from Vim help (|CursorHold-example|).
" The only changes are:
" (1) if w != ""               becomes       if w =~ "\k"
" (2) exe "silent! ptag " . w  becomes       exe "silent! psearch " . w
" * The first change prevents PreviewWord of searching while cursor is on some
"   non-keyword characters, e.g. braces, asterisks, etc.
function! s:PreviewWord() abort
  if &previewwindow " don't do this in the preview window
    return
  endif
  " let w = expand("<cword>") " get the word under cursor
  let w = GetNearestKeyword() " get the word under cursor
  if w =~ '\k\+' " if there is one ':ptag' to it

    " Delete any existing highlight before showing another tag
    silent! wincmd P " jump to preview window
    if &previewwindow " if we really get there...
      match none " delete existing highlight
      wincmd p " back to old window
    endif

    " Try previewing a matching tag for the word under the cursor
    let v:errmsg = ""
    " doing a search this way (ie, pattern ended by '\s*(') gives a better
    " chance to find a function prototype
    exe "silent! psearch /" . w .'\s*(/'
    " exe "silent! psearch " . w
    if v:errmsg =~ "tag not found"
      return
    endif

    silent! wincmd P " jump to preview window
    if &previewwindow " if we really get there...
      if has("folding")
        silent! .foldopen " don't want a closed fold
      endif
      call search("$", "b") " to end of previous line
      let w = substitute(w, '\', '\\\', "")
      call search('\<\V' . w . '\>') " position cursor on match
      " Add a match highlight to the word at this position
      hi previewWord term=bold ctermbg=green guibg=green
      exe 'match previewWord "\%' . line(".") . 'l\%' . col(".") . 'c\k*"'
      wincmd p " back to old window
    endif
  endif
endfunction
"------------------------------------------------------------------------
" s:PreviewFunctionSignature() {{{3
" Note:
" When you open a parenthesis after a function name, and at the line end, that
" function's definition is previewed through PreviewWord().
" This is inspired from Delphi's CodeInsight technology.
" Something similar (PreviewClassMembers) could be written for the C++ users,
" for previewing the class members when you type a dot after an object name.
" If somebody decides to write it, please, mail it to me.
function! s:PreviewFunctionSignature() abort
    " let CharOnCursor = strpart( getline('.'), col('.')-2, 1)
    if col(".") == col("$")
        call s:PreviewWord()
    endif
    return "("
endfunction
"------------------------------------------------------------------------
" s:DoPreviewWord(), automatically called when the cursor is holded {{{3
function! s:DoPreviewWord() abort
  if g:preview_if_hold
    call s:PreviewWord()
  endif
endfunction

" }}}1
  let &cpo = s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
