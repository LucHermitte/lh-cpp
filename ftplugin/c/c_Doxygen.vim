"=============================================================================
" File:		ftplugin/c/c_Doxygen.vim                                  {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.2.0
let s:k_version = 220
" Created:	22nd Nov 2005
" Last Update:	17th Dec 2019
"------------------------------------------------------------------------
" Description:
" 	Provides the command :DOX that expands a doxygened documentation for
" 	the current C|C++ function.
"
" 	:DOX tries to guess various things like:
" 	- the direction ([in], [out], [in,out]) of the parameters
" 	- pointers that should not be null
" 	- ...
"
" 	It also comes with the following template-file:
" 	- a\%[uthor-doxygen] + CTRL-R_TAB
"
"
" Options:
" 	- [bg]:[&ft_]dox_CommentLeadingChar
" 	- [bg]:[&ft_]dox_TagLeadingChar
" 	- [bg]:[&ft_]dox_author_tag
" 	- [bg]:[&ft_]dox_ingroup
" 	- [bg]:[&ft_]dox_brief
" 	- [bg]:[&ft_]dox_throw
"
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" Dependencies:	Mu-template
" }}}1
"=============================================================================

if version < 700
  finish " Vim 7 required
endif

"=============================================================================
" Avoid buffer reinclusion {{{1
if exists('b:loaded_ftplug_c_Doxygen') && !exists('g:force_reload_c_Doxygen')
  finish
endif
let b:loaded_ftplug_c_Doxygen = s:k_version

let s:cpo_save=&cpo
set cpo&vim
" }}}1
"------------------------------------------------------------------------
" Commands and mappings {{{1

" todo: arguments (with auto completion) for brief, ingroup, author, since, ...
" todo: align arguments and their descriptions

command! -buffer -nargs=0 DOX :call lh#dox#doxygenize()

" Commands and mappings }}}1
"=============================================================================
" Avoid global reinclusion {{{1
if exists("s:loaded_c_Doxygen")
      \ && !exists('g:force_reload_c_Doxygen')
  let &cpo=s:cpo_save
  finish
endif
let s:loaded_c_Doxygen_vim = 1
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Functions {{{1
function! CppDox_snippet(tagname, commentLeadingChar)
  call lh#notify#deprecated('CppDox_snippet', 'lh#dox#snippet')
  return lh#dox#snippet(a:tagname, a:commentLeadingChar)
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
