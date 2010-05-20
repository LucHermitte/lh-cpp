"=============================================================================
" $Id$
" File:		ftplugin/cpp/cpp_Constructor.vim                          {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	09th Feb 2009
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:
" 	Helper MMIs to generate constructors 
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	
" 	v1.1.0: creation
" TODO:		«missing features»
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_cpp_Constructor") && !exists('g:force_reload_ftplug_cpp_Constructor'))
  finish
endif
let b:loaded_ftplug_cpp_Constructor = 100
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=? Constructor :call lh#cpp#constructors#Main(<f-args>)

"=============================================================================
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
