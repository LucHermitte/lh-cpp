"=============================================================================
" File:		ftplugin/cpp/cpp_Constructor.vim                          {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/tree/master/License.md>
" Version:	2.2.1
" Created:	09th Feb 2009
" Last Update:	16th Jan 2019
"------------------------------------------------------------------------
" Description:
" 	Helper MMIs to generate constructors
"
"------------------------------------------------------------------------
" Installation:	«install details»
" History:
" 	v1.1.0: creation
"	v.2.0.0b4
"	        New commands: :ConstructorCopy, :ConstructorDefault,
"	        :ConstructorInit, :AssignmentOperator
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
let s:cpo_save=&cpo
set cpo&vim
if &cp || (exists("b:loaded_ftplug_cpp_Constructor")
      \ && !exists('g:force_reload_ftplug_cpp_Constructor'))
  let &cpo=s:cpo_save
  finish
endif
let b:loaded_ftplug_cpp_Constructor = 221
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=?  -complete=customlist,lh#cpp#constructors#_complete
      \              Constructor        :call lh#cpp#constructors#Main(<f-args>)
command! -b -nargs=0 ConstructorInit    :call lh#cpp#constructors#InitConstructor()
command! -b -nargs=0 ConstructorCopy    :call lh#cpp#constructors#GenericConstructor('copy')
command! -b -nargs=0 ConstructorDefault :call lh#cpp#constructors#GenericConstructor('default')
command! -b -nargs=0 AssignmentOperator :call lh#cpp#constructors#AssignmentOperator()

"=============================================================================
"}}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
