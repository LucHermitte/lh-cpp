"=============================================================================
" $Id$
" File:		ftplugin/c/c_stl.vim
" Author:	Luc Hermitte <EMAIL:hermitte at free.fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	24th oct 2002
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	Show current the name of the current function, we are within,
" 		on status line.
" 
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
"=============================================================================
" Local Definitions: {{{
" Avoid reinclusion
finish
" deactivated because it could be very, very slow in some cases
if exists('b:loaded_ftplug_c_stl') | finish | endif
let b:loaded_ftplug_c_stl = 1
"
let s:cpo_save=&cpo
set cpo&vim
"
"------------------------------------------------------------------------
" setlocal stl=%{C_ShowFuncName()}
" setlocal statusline=%<%f%h%{1==&modified?'[+]':''}%r%=\ %-16(%l,%c%V\ %)\ %P
" setlocal statusline=%-30(%<%f\ %h%{1==&modified?'[+]':''}%r%)%{C_ShowFuncName()}%=\ %-16(%l,%c%V\ %)\ %P
setlocal statusline=%<%f\ %h%{1==&modified?'[+]':''}%r%{C_ShowFuncName()}%=\ %-16(%l,%c%V\ %)\ %P
" }}}
"=============================================================================
" Global Definitions: {{{
if exists("g:loaded_c_stl") 
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_c_stl = 1
"------------------------------------------------------------------------
" Function: C_ShowFuncName() {{{
function! C_ShowFuncName()
  let s:type = '\<\I\i*\>'
  let s:name = '\%(::\)\=\<\I\i*\>\%(::\<\I\i*\>\)*'
  let s:param= '[^)]\+'

  " spaces, line-breaks, C comments or C++ comments
  let s:blan0='\%(//.*$\|\_s\|/\*.\{-}\*/\)*'
  let s:blank_ne0='\%(\_s\|/\*.\{-}\*/\|//.*$\)\+'

  " let s:blank0='\%(//.*$\|\_s\|/\*.\{-}\*/\)*'
  " let s:blank_ne0='\%(\_s\|/\*.\{-}\*/\|//.*$\)\+'
  " let s:blank = '\%('.s:blank0.'\)\@>'
  " let s:blank_ne = '\%('.s:blank_ne0.'\)\@>'

  let s:begin= '\%(\%^\|[;}]\)'.s:blank.'\zs'

  let s:function= s:type. s:blank_ne .s:name.s:blank
	\ .'(\%('.s:blank_ne.'\|'.s:param.'\)*)'
	\ .s:blank.'\%(\<const\>\)\='.s:blank
	" \ .'(\%('.s:param.'\)*)'
  let g:fn = s:function

  let l1 = 0
  let l2 = line('.')+1
  while 1
    let l2 = searchpair( '{\_[^{]*\%<'.l2.'l', '', '}', 'bnW' )
    if l2 <= 0 
      return '' | endif
    " let l1 = searchpair( s:function.'\%'.l2.'l{', '', '\%$', 'bnW' ) 
    let l1 = searchpair( s:function.'\%'.l2.'l{', '', '}', 'bnW' ) 
    if l1 > 0 | break | endif
  endwhile
    call confirm('l1='.l1, '&ok', 1)


	" \ what_is_good_to_skip_comments)

  " ... then getlines from line l (if > 0) to '{'.
  if l1 <= 0 | return '' | endif
  let l = exists('r') ? r : ''
  let ln=line('$')
  while l1 < ln
    let l = l. substitute(getline(l1), s:blank_ne, ' ', 'g')
    if -1 != match(l, '{')
      let l = substitute(l, '\s\+\|{.*$', ' ', 'g')
      return ' -> '.l
    endif
    let l1 = l1 + 1
  endwhile
endfunction
" }}}
"------------------------------------------------------------------------
let &cpo=s:cpo_save
" }}}
"=============================================================================
" vim600: set fdm=marker:
