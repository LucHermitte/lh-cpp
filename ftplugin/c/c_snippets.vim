"=============================================================================
" File:         ftplugin/c/c_snippets.vim                               {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/License.md>
" Version:      2.2.0
let s:k_version = '220'
" Created:      14th Apr 2008
" Last Update:  30th Apr 2019
"------------------------------------------------------------------------
" Description:  Snippets of C Control Statements
"
"------------------------------------------------------------------------
" Dependencies: lh-vim-lib
"               a.vim                   -- alternate files
"               VIM >= 7.3 only
"
" History:
" 06th,26th Mar 2006: InsertReturn() for smart insertion of return.
" for changelog: 27th Jun 2006 -> C_SelectExpr4Surrounding used in
"                                 <leader><leader> mappings
" TODO:         «missing features»
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if (exists("b:loaded_ftplug_c_snippets") && !exists('g:force_reload_ftplug_c_snippets')) || get(g:, 'lh_cpp_snippets', 1) == 0
  finish
endif
let s:cpo_save=&cpo
set cpo&vim
let b:loaded_ftplug_c_snippets = s:k_version
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

" Some C++ abbreviated Keywords {{{3
" ------------------------------------------------------------------------
" Are you also dyslexic ?
inoreab <buffer> ocnst      const
inoreab <buffer> earse      erase

" C keywords {{{3
" ------------------------------------------------------------------------
" Pre-processor
"
"-- insert "#define" at start of line
" iab  <buffer> <m-d>  <C-R>=lh#map#no_context("\<M-d> ",'\<esc\>0i#define')<CR>
iab <silent> <buffer> #d     <C-R>=lh#map#no_context("#d ",'\<esc\>0i#define')<CR>
"-- insert "#include" at start of line
" iab  <buffer> <m-i>  <C-R>=lh#map#no_context("\<M-i> ",'\<esc\>0i#include')<CR>
iab <silent> <buffer> #n    <C-R>=lh#map#no_context("#n ",'\<esc\>0i#include')<CR>

"-- insert "#ifdef/endif" at start of line
iab <silent> <buffer> #i    <C-R>=lh#map#no_context('#i ','\<esc\>0i#ifdef')<CR>
iab <silent> <buffer> #e    <C-R>=lh#map#no_context("#e ",'\<esc\>0i#endif')<CR>

"-- surrounds with "#if 0 ... endif"
:Brackets #if\ 0 #endif -insert=0 -nl -trigger=<localleader>0
xmap <buffer> <localleader><k0> <localleader>0
nmap <buffer> <localleader><k0> <localleader>0
:Brackets #if\ 0 #else!mark!\n#endif -insert=0 -nl -trigger=<localleader>1
xmap <buffer> <localleader><k1> <localleader>1
nmap <buffer> <localleader><k1> <localleader>1

" ------------------------------------------------------------------------
" Control statements {{{3
" ------------------------------------------------------------------------
"
nnoremap <Plug>C_SelectExpr4Surrounding :call lh#cpp#snippets#select_expr_4_surrounding()<cr>

" --- if ---------------------------------------------------------{{{4
"--if    insert "if" statement                   {{{5
  Inoreabbr <buffer> <silent> if <C-R>=lh#cpp#snippets#def_abbr('if ',
        \ '\<c-f\>if(!cursorhere!){!mark!}!mark!')<cr>
"--,if    insert "if" statement
  xnoremap <buffer> <silent> <localleader>if
        \ <c-\><c-n>@=lh#style#surround('if(!cursorhere!){', '}!mark!',
        \ 0, 1, '', 1, 'if ')<cr>
  xnoremap <buffer> <silent> <LocalLeader><localleader>if
        \ <c-\><c-n>@=lh#style#surround('if(', '!cursorhere!) {!mark!}!mark!',
        \ 0, 1, '', 1, 'if ')<cr>
      nmap <buffer> <LocalLeader>if V<LocalLeader>if
      nmap <buffer> <LocalLeader><LocalLeader>if
            \ <Plug>C_SelectExpr4Surrounding<LocalLeader><LocalLeader>if

"--elif  insert «else if () { ... }»             {{{5
  Inoreabbr <buffer> <silent> elif <C-R>=lh#cpp#snippets#def_abbr('elif ',
        \ '\<c-f\>else if(!cursorhere!) {!mark!}!mark!')<cr>
"--,elif  insert else clause of if statement with following if statement
  xnoremap <buffer> <silent> <localleader>elif
        \ <c-\><c-n>@=lh#style#surround('else if(!cursorhere!){', '}!mark!',
        \ 0, 1, '', 1, 'elif ')<cr>
  xnoremap <buffer> <silent> <localleader><localleader>elif
        \ <c-\><c-n>@=lh#style#surround('else if(', '!cursorhere!){!mark!}!mark!',
        \ 0, 1, '', 1, 'elif ')<cr>
      nmap <buffer> <localleader><LocalLeader>elif
            \ <Plug>C_SelectExpr4Surrounding<localleader><LocalLeader>elif
      nmap <buffer> <LocalLeader>elif V<LocalLeader>elif

"--else  insert else clause of if statement      {{{5
  Inoreabbr <buffer> <silent> else <C-R>=lh#cpp#snippets#insert_if_not_before('else ',
        \ '\<c-f\>else{!cursorhere!}!mark!', 'if')<cr><c-f>
"--,else  insert else clause of if statement
  xnoremap <buffer> <silent> <localleader>else
        \ <c-\><c-n>@=lh#style#surround('else {', '}',
        \ 0, 1, '``l', 1, 'else ')<cr>
      nmap <buffer> <LocalLeader>else V<LocalLeader>else

"--- for ---------------------------------------------------------{{{4
"--for   insert "for" statement
" TODO: pb when c_nl_before_bracket = 1, cursor is not placed correctly
  Inoreabbr <buffer> <silent> for <C-R>=lh#cpp#snippets#def_abbr('for ',
      \ {
      \ '! lh#cpp#use_cpp11()': '\<c-f\>for(!cursorhere!;!mark!;!mark!){!mark!}!mark!',
      \ '  lh#cpp#use_cpp11()': '\<c-f\>for(!cursorhere!){!mark!}!mark!'
      \ })<cr>
"--,for   insert "for" statement
  xnoremap <buffer> <silent> <localleader>for
        \ <c-\><c-n>@=lh#style#surround('for(!cursorhere!;!mark!;!mark!){', '}!mark!',
        \ 0, 1, '', 1, 'for ')<cr>
      nmap <buffer> <LocalLeader>for V<LocalLeader>for

"--- while -------------------------------------------------------{{{4
"--while insert "while" statement
  Inoreabbr <buffer> <silent> while <C-R>=lh#cpp#snippets#def_abbr('while ',
        \ '\<c-f\>while(!cursorhere!){!mark!}!mark!')<cr>
"--,while insert "while" statement
  xnoremap <buffer> <silent> <localleader>wh
        \ <c-\><c-n>@=lh#style#surround('while(!cursorhere!){', '}!mark!',
        \ 0, 1, '', 1, 'while ')<cr>

  xnoremap <buffer> <silent> <localleader><localleader>wh
        \ <c-\><c-n>@=lh#style#surround('while(',
        \ '!cursorhere!){!mark!}!mark!',
        \ 0, 1, '', 1, 'while ')<cr>
  " Note: \<esc\>lcw is used to strip every spaces at the beginning of the
  " selected-area
      nmap <buffer> <LocalLeader>while V<LocalLeader>wh
      nmap <buffer> <LocalLeader><LocalLeader>while
            \ <Plug>C_SelectExpr4Surrounding<LocalLeader><LocalLeader>wh

"--- do ----------------------------------------------------------{{{4
"--do insert "do" statement
  Inoreabbr <buffer> <silent> do <C-R>=lh#cpp#snippets#def_abbr('do ',
        \ '\<c-f\>do{!cursorhere!}while(!mark!);!mark!')<cr><c-f>
"--,do insert "do" statement
  xnoremap <buffer> <silent> <localleader>do
        \ <c-\><c-n>@=lh#style#surround('do{', '!cursorhere!}while(!mark!);!mark!',
        \ 0, 1, '', 1, 'do ')<cr>
  xnoremap <buffer> µ
        \ <c-\><c-n>@=SurroundBySubstitute('do{', '!cursorhere!}while(!mark!);!mark!',
        \ 0, 1, '', 1, 'do ')<cr>
  " problem here with fix_indent !!!

  xnoremap <buffer> <silent> <localleader><localleader>do
        \ <c-\><c-n>@=Surround('do{!cursorhere!}while(',
        \ ');!mark!',
        \ 0, 1, '', 1, 'do ')<cr>
  xnoremap <buffer> <localleader><localleader>d2
        \ <c-\><c-n>@=SurroundBySubstitute('do{!cursorhere!}while(',
        \ ');!mark!',
        \ 0, 1, '', 1, 'do ')<cr>
  " Note: \<esc\>lcw is used to strip every spaces at the beginning of the
  " selected-area
      nmap <buffer> <LocalLeader>do V<LocalLeader>do
      nmap <buffer> <LocalLeader><LocalLeader>do
            \ <Plug>C_SelectExpr4Surrounding<LocalLeader><LocalLeader>do

"--- switch ------------------------------------------------------{{{4
"--switch insert "switch" statement
  Inoreabbr <buffer> <silent> switch <C-R>=lh#cpp#snippets#def_abbr('switch ',
        \ '\<c-f\>switch(!cursorhere!){!mark!}!mark!')<cr>
"--,switch insert "switch" statement
  xnoremap <buffer> <silent> <localleader>switch
        \ <c-\><c-n>@=lh#style#surround('switch(!cursorhere!){case !mark!:',
        \ '}!mark!', 1, 1, '', 1, 'switch ')<cr>
      nmap <buffer> <LocalLeader>switch V<LocalLeader>switch

"--- {\n} --------------------------------------------------------{{{4
  " xnoremap <buffer> <silent> <localleader>{
        " \ <c-\><c-n>@=lh#style#surround('{!cursorhere!', '}!mark!',
        " \ 1, 1, '', 1, ',{ ')<cr>
      " nmap <buffer> <LocalLeader>{ V<LocalLeader>{

" --- return -----------------------------------------------------{{{4
"-- <m-r> insert "return ;"
  inoremap <buffer> <m-r> <c-r>=lh#cpp#snippets#insert_return()<cr>

" --- ?: ---------------------------------------------------------{{{4
"-- ?: insert "? : ;"
  inoremap <buffer> ?: <c-r>=lh#map#build_map_seq('() ?!mark!:!mark!\<esc\>F(a')<cr>

"--- Commentaires automatiques -----------------------------------{{{4
"--/* insert /*<curseur>*/
  Brackets /* */ -visual=0
  Brackets /* */ -visual=0 -trigger=<kDivide><kMultiply>
"--<*M-v>- Surrounds a selection (/word) with C comments.
  Brackets /* */ -insert=0 -trigger=<m-v>

"--/*- insert /*-----[  ]-------*/
  inoreab <buffer> /- 0<c-d>/*<esc>75a-<esc>a*/<esc>45<left>R[

"--/*= insert /*=====[  ]=======*/
  inoreab <buffer> /= 0<c-d>/*<esc>75a=<esc>a*/<esc>45<left>R[


" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
