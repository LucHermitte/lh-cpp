"=============================================================================
" $Id$
" File:		ftplugin/cpp/cpp_Inspect.vim                             {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
" Created:	11th Sep 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
" 	C++ ftplugin that provides command to inpect various information:
" 	- ancestor of a class
" 	- children of a class
" }}}1
"=============================================================================

let s:k_version = 200
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_cpp_Inspect") && !exists('g:force_reload_ftplug_cpp_Inspect'))
  finish
endif
let b:loaded_ftplug_cpp_Inspect = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=? Ancestors 
      \ echo lh#dev#option#call('class#ancestors', &ft, lh#cpp#ftplugin#OptionalClass(<q-args>))
command! -b -nargs=? -bang Children  call s:Children("<bang>", <f-args>)

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_cpp_Inspect") && !exists('g:force_reload_ftplug_cpp_Inspect'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_cpp_Inspect = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/cpp/«cpp_Inspect».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.

" s:Children(bang [, namespace [,classname]]
function! s:Children(bang, ...)
  let reset_namespace_cache = a:bang == "!"
  let namespace = a:0 > 0 ? (a:1) : ''
  let classname = lh#cpp#ftplugin#OptionalClass(a:000[1:])
  let children = lh#dev#option#call('class#fetch_direct_children', &ft,
	\ classname, namespace, reset_namespace_cache)
  " lh#cpp#AnalysisLib_Class#FetchDirectChildren(classname, a:namespace, reset_namespace_cache)
  echo children
endfunction

" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
