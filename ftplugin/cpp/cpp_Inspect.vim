"=============================================================================
" $Id$
" File:		ftplugin/cpp/cpp_Inspect.vim                             {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	11th Sep 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
" 	C++ ftplugin that provides command to inpect various information:
" 	- ancestor of a class
" 	- children of a class
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_cpp_Inspect") && !exists('g:force_reload_ftplug_cpp_Inspect'))
  finish
endif
let b:loaded_ftplug_cpp_Inspect = 100
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=? Ancestors 
      \ echo lh#cpp#AnalysisLib_Class#Ancestors(lh#cpp#ftplugin#OptionalClass(<q-args>))
command! -b -nargs=+ -bang Children  call s:Children("<bang>", <f-args>)

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_cpp_Inspect") && !exists('g:force_reload_ftplug_cpp_Inspect'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_cpp_Inspect = 100
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/cpp/«cpp_Inspect».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.

function! s:Children(bang, namespace, ...)
  let reset_namespace_cache = a:bang == "!"
  let classname = lh#cpp#ftplugin#OptionalClass(a:000)
  let children = lh#cpp#AnalysisLib_Class#FetchDirectChildren(classname, a:namespace, reset_namespace_cache)
  echo children
endfunction

" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
