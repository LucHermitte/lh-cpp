"=============================================================================
" $Id$
" File:		ftplugin/c/c_snippets.vim                               {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
" Created:	14th Apr 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	Snippets of C Control Statements
" 
"------------------------------------------------------------------------
" Dependancies:	lh-vim-lib
" 		a.vim			-- alternate files
" 		VIM >= 6.00 only
"
" History:
" 06th,26th Mar 2006: InsertReturn() for smart insertion of return.
" for changelog: 27th Jun 2006 -> C_SelectExpr4Surrounding used in
"                                 <leader><leader> mappings
" TODO:		«missing features»
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if (exists("b:loaded_ftplug_c_snippets") && !exists('g:force_reload_ftplug_c_snippets')) || lh#option#get("lh_cpp_snippets", 1, "g") == 0
  finish
endif
let s:cpo_save=&cpo
set cpo&vim
let b:loaded_ftplug_c_snippets = 200
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" This must be loaded before continuing
runtime! ftplugin/c/c_localleader.vim

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
iab  <buffer> <m-d>  <C-R>=MapNoContext("\<M-d> ",'\<esc\>0i#define')<CR>
iab  <buffer> #d     <C-R>=MapNoContext("#d ",'\<esc\>0i#define')<CR>
"-- insert "#include" at start of line
iab  <buffer> <m-i>  <C-R>=MapNoContext("\<M-i> ",'\<esc\>0i#include')<CR>
iab  <buffer> #n    <C-R>=MapNoContext("#n ",'\<esc\>0i#include')<CR>

"-- insert "#ifdef/endif" at start of line
iab  <buffer> #i    <C-R>=MapNoContext('#i ','\<esc\>0i#ifdef')<CR>
iab  <buffer> #e    <C-R>=MapNoContext("#e ",'\<esc\>0i#endif')<CR>

"-- surrounds with "#if 0 ... endif"
:Brackets #if\ 0 #endif -insert=0 -nl -trigger=<localleader>0
vmap <buffer> <localleader><k0> <localleader>0
nmap <buffer> <localleader><k0> <localleader>0
:Brackets #if\ 0 #else\ \n#endif -insert=0 -nl -trigger=<localleader>1
vmap <buffer> <localleader><k1> <localleader>1
nmap <buffer> <localleader><k1> <localleader>1

" ------------------------------------------------------------------------
" Control statements {{{3
" ------------------------------------------------------------------------
"
nnoremap <Plug>C_SelectExpr4Surrounding :call C_SelectExpr4Surrounding()<cr>

" --- if ---------------------------------------------------------{{{4
"--if    insert "if" statement                   {{{5
  Inoreabbr <buffer> <silent> if <C-R>=Def_AbbrC('if ',
	\ '\<c-f\>if (!cursorhere!) {\n!mark!\n}!mark!')<cr>
"--,if    insert "if" statement
  vnoremap <buffer> <silent> <localleader>if 
	\ <c-\><c-n>@=Surround('if (!cursorhere!) {', '}!mark!',
	\ 1, 1, '', 1, 'if ')<cr>
  vnoremap <buffer> <silent> <LocalLeader><localleader>if 
	\ <c-\><c-n>@=Surround('if (', '!cursorhere!) {\n!mark!\n}!mark!',
	\ 0, 1, '', 1, 'if ')<cr>
      nmap <buffer> <LocalLeader>if V<LocalLeader>if
      nmap <buffer> <LocalLeader><LocalLeader>if
	    \ <Plug>C_SelectExpr4Surrounding<LocalLeader><LocalLeader>if

"--elif  insert «else if () { ... }»             {{{5
  Inoreabbr <buffer> <silent> elif <C-R>=Def_AbbrC('elif ',
	\ '\<c-f\>else if (!cursorhere!) {\n!mark!\n}!mark!')<cr>
"--,elif  insert else clause of if statement with following if statement
  vnoremap <buffer> <silent> <localleader>elif 
	\ <c-\><c-n>@=Surround('else if (!cursorhere!) {', '}!mark!',
	\ 1, 1, '', 1, 'elif ')<cr>
  vnoremap <buffer> <silent> <localleader><localleader>elif 
	\ <c-\><c-n>@=Surround('else if (', '!cursorhere!) {\n!mark!\n}!mark!',
	\ 0, 1, '', 1, 'elif ')<cr>
      nmap <buffer> <localleader><LocalLeader>elif 
	    \ <Plug>C_SelectExpr4Surrounding<localleader><LocalLeader>elif
      nmap <buffer> <LocalLeader>elif V<LocalLeader>elif

"--else  insert else clause of if statement      {{{5
  Inoreabbr <buffer> <silent> else <C-R>=InsertIfNotBefore('else ',
	\ '\<c-f\>else {\n!cursorhere!\n}!mark!', 'if')<cr><c-f>
"--,else  insert else clause of if statement
  vnoremap <buffer> <silent> <localleader>else
	\ <c-\><c-n>@=Surround('else {', '}',
	\ 1, 1, '``l', 1, 'else ')<cr>
      nmap <buffer> <LocalLeader>else V<LocalLeader>else

"--- for ---------------------------------------------------------{{{4
"--for   insert "for" statement
" TODO: pb when c_nl_before_bracket = 1, cursor is not placed correctly
  Inoreabbr <buffer> <silent> for <C-R>=Def_AbbrC('for ',
      \ '\<c-f\>for (!cursorhere!;!mark!;!mark!) {\n!mark!\n}!mark!')<cr>
"--,for   insert "for" statement
  vnoremap <buffer> <silent> <localleader>for 
	\ <c-\><c-n>@=Surround('for (!cursorhere!;!mark!;!mark!) {', '}!mark!',
	\ 1, 1, '', 1, 'for ')<cr>
      nmap <buffer> <LocalLeader>for V<LocalLeader>for

"--- while -------------------------------------------------------{{{4
"--while insert "while" statement
  Inoreabbr <buffer> <silent> while <C-R>=Def_AbbrC('while ',
	\ '\<c-f\>while (!cursorhere!) {\n!mark!\n}!mark!')<cr>
"--,while insert "while" statement
  vnoremap <buffer> <silent> <localleader>wh 
	\ <c-\><c-n>@=Surround('while (!cursorhere!) {', '}!mark!',
	\ 1, 1, '', 1, 'while ')<cr>

  vnoremap <buffer> <silent> <localleader><localleader>wh 
	\ <c-\><c-n>@=Surround('while (', 
	\ '!cursorhere!) {\n!mark!\n}!mark!',
	\ 0, 1, '', 1, 'while ')<cr>
  " Note: \<esc\>lcw is used to strip every spaces at the beginning of the
  " selected-area
      nmap <buffer> <LocalLeader>while V<LocalLeader>wh
      nmap <buffer> <LocalLeader><LocalLeader>while 
	    \ <Plug>C_SelectExpr4Surrounding<LocalLeader><LocalLeader>wh

"--- do ----------------------------------------------------------{{{4
"--do insert "do" statement
  Inoreabbr <buffer> <silent> do <C-R>=Def_AbbrC('do ',
	\ '\<c-f\>do {\n!cursorhere!\n} while (!mark!) ;!mark!')<cr><c-f>
"--,do insert "do" statement
  vnoremap <buffer> <silent> <localleader>do 
	\ <c-\><c-n>@=Surround('do {', '!cursorhere!} while (!mark!);!mark!',
	\ 1, 1, '', 1, 'do ')<cr>
  vnoremap <buffer> µ 
	\ <c-\><c-n>@=SurroundBySubstitute('do {', '!cursorhere!} while (!mark!);!mark!',
	\ 1, 1, '', 1, 'do ')<cr>
  " problem here with fix_indent !!!

  vnoremap <buffer> <silent> <localleader><localleader>do 
	\ <c-\><c-n>@=Surround('do {\n!cursorhere!\n}\nwhile (', 
	\ ');!mark!',
	\ 0, 1, '', 1, 'do ')<cr>
  vnoremap <buffer> <localleader><localleader>d2 
	\ <c-\><c-n>@=SurroundBySubstitute('do {\n!cursorhere!\n}\nwhile (', 
	\ ');!mark!',
	\ 0, 1, '', 1, 'do ')<cr>
  " Note: \<esc\>lcw is used to strip every spaces at the beginning of the
  " selected-area
      nmap <buffer> <LocalLeader>do V<LocalLeader>do
      nmap <buffer> <LocalLeader><LocalLeader>do 
	    \ <Plug>C_SelectExpr4Surrounding<LocalLeader><LocalLeader>do

"--- switch ------------------------------------------------------{{{4
"--switch insert "switch" statement
  Inoreabbr <buffer> <silent> switch <C-R>=Def_AbbrC('switch ',
	\ '\<c-f\>switch (!cursorhere!) {\n!mark!\n}!mark!')<cr>
"--,switch insert "switch" statement
  vnoremap <buffer> <silent> <localleader>switch 
	\ <c-\><c-n>@=Surround('switch (!cursorhere!) {\ncase !mark!:',
	\ '}!mark!', 1, 1, '', 1, 'switch ')<cr>
      nmap <buffer> <LocalLeader>switch V<LocalLeader>switch

"--- {\n} --------------------------------------------------------{{{4
  " vnoremap <buffer> <silent> <localleader>{
	" \ <c-\><c-n>@=Surround('{!cursorhere!', '}!mark!',
	" \ 1, 1, '', 1, ',{ ')<cr>
      " nmap <buffer> <LocalLeader>{ V<LocalLeader>{

"--- main --------------------------------------------------------{{{4
"--Ymain  insert "main" routine
  Iabbr  <buffer> Ymain  int main (int argc, char **argv!jump-and-del!<cr>{
"--,main  insert "main" routine
  map <buffer> <LocalLeader>main  iint main (int argc, char **argv)<cr>{


" --- return -----------------------------------------------------{{{4
"-- <m-r> insert "return ;"
  inoremap <buffer> <m-r> <c-r>=InsertReturn()<cr>

" --- ?: ---------------------------------------------------------{{{4
"-- ?: insert "? : ;"
  inoremap <buffer> ?: <c-r>=BuildMapSeq('() ?!mark!:!mark!\<esc\>F(a')<cr>

"--- Commentaires automatiques -----------------------------------{{{4
"--/* insert /* <curseur>
"             */
  if &ft !~ '^\(cpp\|java\)$'
    " inoremap <buffer> /*<space> <c-r>=Def_AbbrC('/*',
	  " \ '/*\<cr\>\<BS\>/!mark!\<up\>\<end\>')<cr>
    inoreab <buffer> /* <c-r>=Def_AbbrC('/*', '/*!cursorhere!\n/!mark!')<cr>
  endif

"--/*- insert /*-----[  ]-------*/
  inoreab <buffer> /- 0<c-d>/*<esc>75a-<esc>a*/<esc>45<left>R[

"--/*= insert /*=====[  ]=======*/
  inoreab <buffer> /= 0<c-d>/*<esc>75a=<esc>a*/<esc>45<left>R[

"--<*M-v>- Surrounds a selection (/word) with C comments.
  " Todo: harmonize with EnhanceCommentify mappings
  vnoremap <buffer> <M-v>
	\ <c-\><c-n>@=Surround('/*', '!mark!*/', 
	\ 0, 0, '', 1, '/*')<cr>
      nmap <buffer> <M-v> viw<M-v>
"}}}

"------------------------------------------------------------------------
" Local commands {{{2


"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if exists("g:loaded_ftplug_c_snippets") && !exists('g:force_reload_ftplug_c_snippets')
  let &cpo=s:cpo_save
  finish
endif
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2

" Def_MapC(key, expr1, expr2) {{{3
function! Def_MapC(key,expr1,expr2)
  if exists('b:usemarks') && b:usemarks
    return "\<c-r>=MapNoContext2('".a:key."',BuildMapSeq('".a:expr2."'))\<cr>"
    " return "\<c-r>=MapNoContext2('".a:key."',BuildMapSeq(\"".a:expr2."\"))\<cr>"
  else
    return "\<c-r>=MapNoContext2('".a:key."', '".a:expr1."')\<cr>"
    " return "\<c-r>=MapNoContext2('".a:key."', \"".a:expr1."\")\<cr>"
  endif
endfunction

" Def_AbbrC(key,expr) {{{3
function! Def_AbbrC(key,expr)
  " Special handling of preprocessor context
  if getline('.') =~ '^\s*#'
    return a:key
  endif
  " Default behaviour
  let rhs = a:expr
  if lh#cpp#option#nl_before_bracket()
    " let rhs = substitute(rhs, '\(BuildMapSeq\)\@<!(', '\\<cr\\>\0', 'g')
    let rhs = substitute(rhs, '\s*(', '\\n(', 'g')
  endif
  if lh#cpp#option#nl_before_curlyB()
    " let rhs = substitute(rhs, '{', '\\<cr\\>\0', 'g')
    let rhs = substitute(rhs, '\s*{', '\\n{', 'g')
    let rhs = substitute(rhs, '}\s*', '}\\n', 'g')
  endif
  return InsertSeq(a:key, rhs)
endfunction

" Goto_ReturnSemiColon() {{{3
function! Goto_ReturnSemiColon()
  let p = getpos('.')
  let r = search('return.*;', 'e')
  if r == 0 | call setpos('.', p) | endif
endfunction

" InsertReturn() {{{3
function! InsertReturn()
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, c)
  if l =~ '^\s*$'
    return BuildMapSeq('return ;!mark!\<esc\>==0:call Goto_ReturnSemiColon()\<cr\>i')
  else
    let spacesLen = strlen(matchstr(l, '^\s*'))
    let stripCmd = (spacesLen!=0) ? '\<esc\>'.'ct'.l[spacesLen] : ''
    echo stripCmd
    if stridx(l, ';') != -1
      return BuildMapSeq(stripCmd.'return \<esc\>==0:call Goto_ReturnSemiColon()\<cr\>a')
    elseif stridx(l, '}') != -1
      return BuildMapSeq(stripCmd.'return ;!mark!\<esc\>==0:call Goto_ReturnSemiColon()\<cr\>i')
    else
      return BuildMapSeq(stripCmd.'return \<esc\>==A;')
    endif
  endif
endfunction

" InsertReturn0() {{{3
function! InsertReturn0()
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, c)
  if l =~ '^\s*$'
    return BuildMapSeq('return ;!mark!\<esc\>==0f;i')
  else
    let spacesLen = strlen(matchstr(l, '^\s*'))
    let stripCmd = (spacesLen!=0) ? '\<esc\>'.'ct'.l[spacesLen] : ''
    echo stripCmd
    if stridx(l, ';') != -1
      return BuildMapSeq(stripCmd.'return \<esc\>==0f;a')
    elseif stridx(l, '}') != -1
      return BuildMapSeq(stripCmd.'return ;!mark!\<esc\>==0f;i')
    else
      return BuildMapSeq(stripCmd.'return \<esc\>==A;')
    endif
  endif
endfunction

" InsertIfNotAfter(key, what, pattern) {{{3
function! InsertIfNotAfter(key, what, pattern)
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, 0, c)
  if l =~ a:pattern.'\s*$'
    return a:key
  else 
    return Def_AbbrC(a:key, a:what)
  endif
endfunction

" InsertIfNotBefore(key, what, pattern) {{{3
function! InsertIfNotBefore(key, what, pattern)
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, c)
  if l =~ '^\s*'.a:pattern
    return a:key
  else 
    return Def_AbbrC(a:key, a:what)
  endif
endfunction

" C_SelectExpr4Surrounding() {{{3
" todo: fin a better name for the function
function! C_SelectExpr4Surrounding()
  " Go to the first non blank character of the line
  :normal! ^
  " Search either the first semin-colon or the end of the line.
  :call search(';\|\s*$', 'c')
  " If we are not at the end of the line
  if getline('.')[col('.')-1] =~ ';\|\s'
    " If it is followed by blanck characters
    if strpart(getline('.'), col('.')) =~ '^\s*$'
      " then trim the ';' (or the space) and every thing after
      exe "normal! \"_d$"
    else
      " otherwise replace the ';' by a newline character, and goto the end of
      " the previous line (where the line has been cut)
      exe "normal! \"_s\n\<esc>k$"
    endif
  endif
  " And then select till the first non blank character of the line
  :normal! v^
endfunction

" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
