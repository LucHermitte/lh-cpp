"=============================================================================
" $Id$
" File:		ftplugin/cpp/cpp_Constructor.vim                          {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0b4
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
"	v.2.0.0b4
"	        New commands: :ConstructorCopy, :ConstructorDefault,
"	        :ConstructorInit, :AssignmentOperator
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_cpp_Constructor")
      \ && !exists('g:force_reload_ftplug_cpp_Constructor'))
  finish
endif
let b:loaded_ftplug_cpp_Constructor = 200
let s:cpo_save=&cpo
set cpo&vim
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
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
