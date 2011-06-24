"=============================================================================
" $Id$
" File:		ftplugin/c/previewWord.vim
" Author: 	Georgi Slavchev <EMAIL:goyko@gbg.bg>
" 		From <URL:http://vim.sf.net>
" 		Adapted by Luc Hermitte <EMAIL:hermitte at free.fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	?
" Last Update:	$Date$ (21st jul 2002)
"------------------------------------------------------------------------
" Description:	«description» {{{
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
" Installation:	See |lh-cpp-readme.txt|
"=============================================================================
" Buffer definitions {{{
" Avoid reinclusion
if exists('b:loaded_ftplug_previewWord') | finish | endif
let b:loaded_ftplug_previewWord = 1

  "" line continuation used here ??
  let s:cpo_save = &cpo
  set cpo&vim

"------------------------------------------------------------------------
" Mappings {{{
inoremap <buffer> <Plug>PreviewWord <C-o>:call <sid>PreviewWord()<CR>
if !hasmapto('<Plug>PreviewWord', 'i')
  imap <unique> <c-space> <Plug>PreviewWord
endif
nnoremap <buffer> <Plug>PreviewWord :call <sid>PreviewWord()<CR>
if !hasmapto('<Plug>PreviewWord', 'n')
  nmap <unique> <c-space> <Plug>PreviewWord
endif

inoremap <buffer> <Plug>ClosePreviewWindow <C-o>:call <sid>ClosePreviewWindow()<CR>
if !hasmapto('<Plug>ClosePreviewWindow', 'i')
  imap <unique> <c-F10> <Plug>ClosePreviewWindow
endif
nnoremap <buffer> <Plug>ClosePreviewWindow :call <sid>ClosePreviewWindow()<CR>
if !hasmapto('<Plug>ClosePreviewWindow', 'n')
  nmap <unique> <c-F10> <Plug>ClosePreviewWindow
endif

" I've (LH) desactivated the '(' key because I use a bracketing system.
" inoremap <buffer> <c-space> <C-R>=<sid>PreviewFunctionSignature()<CR> 
" }}}
 
" g:preview_if_hold {{{
LetIfUndef g:preview_if_hold 0 
if !exists('*Trigger_Function')
  runtime plugin/Triggers.vim
endif
if exists("*Trigger_Function")
  let x = g:preview_if_hold
  silent call Trigger_DoSwitch('<M-SPACE>',
	\ ':let g:preview_if_hold='.x,':let g:preview_if_hold='.(1-x),1,1)
  imap <buffer> <M-SPACE> <SPACE><ESC><M-SPACE>a<BS>
endif
au! CursorHold *.[ch] nested :call <sid>DoPreviewWord() 
" }}}
" }}}
"=============================================================================
" Global definitions {{{
if exists("g:loaded_previewWord") 
  let &cpo = s:cpo_save
  finish 
endif
let g:loaded_previewWord = 1

setlocal previewheight=4

"------------------------------------------------------------------------
" s:ClosePreviewWindow() {{{
function! s:ClosePreviewWindow()
  silent! wincmd P " jump to preview window 
  if &previewwindow " if we really get there... 
    silent wincmd c " close the window
  endif 
endfunction
" }}}
"------------------------------------------------------------------------
" s:PreviewWord() {{{
" Note: 
" This is literally stolen from Vim help (|CursorHold-example|). 
" The only changes are: 
" (1) if w != ""               becomes       if w =~ "\k" 
" (2) exe "silent! ptag " . w  becomes       exe "silent! psearch " . w 
" * The first change prevents PreviewWord of searching while cursor is on some 
"   non-keyword characters, e.g. braces, asterisks, etc. 
function! s:PreviewWord() 
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
" }}}
"------------------------------------------------------------------------
" s:PreviewFunctionSignature() {{{
" Note: 
" When you open a parenthesis after a function name, and at the line end, that
" function's definition is previewed through PreviewWord(). 
" This is inspired from Delphi's CodeInsight technology. 
" Something similar (PreviewClassMembers) could be written for the C++ users,
" for previewing the class members when you type a dot after an object name. 
" If somebody decides to write it, please, mail it to me. 
function! s:PreviewFunctionSignature() 
    " let CharOnCursor = strpart( getline('.'), col('.')-2, 1) 
    if col(".") == col("$") 
	call s:PreviewWord() 
    endif 
    return "(" 
endfunction 
" }}}
"------------------------------------------------------------------------
" s:DoPreviewWord(), automatically called when the cursor is holded {{{
function! s:DoPreviewWord()
  if g:preview_if_hold
    call s:PreviewWord()
  endif
endfunction
" }}}
" }}}
  let &cpo = s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
