"=============================================================================
" $Id$
" File:		ftplugin/cpp/cpp_refactor.vim                             {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	10th Feb 2005
" Last Update:	$Date$ (10th Feb 2005)
"------------------------------------------------------------------------
" Description:	Some refactoring oriented mappings and commands
" 
" Definitions:
" - :ToInitList
" - :AddBrief
"
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
"
" History:	
" 	v0.1:	10th Feb 2005
" 		Initial version
" }}}1
"=============================================================================


"=============================================================================
" Avoid buffer reinclusion {{{1
if exists('b:loaded_ftplug_cpp_refactor')
       \ && !exists('g:force_reload_cpp_refactor')
  finish
endif
let b:loaded_ftplug_cpp_refactor = 1
 
let s:cpo_save=&cpo
set cpo&vim
" }}}1
"------------------------------------------------------------------------
" Commands and mappings {{{1

" Adds Doxygen's keyword @brief into headers where it is missing.
command! -buffer -range=% AddBrief 
      \ <line1>,<line2>s#\(/\*\*\%(\s*\n\s*\*\)*\)\s*\([^@ ]\)#\1 @brief \u\2

" Changes a list of affectations (instruction) into an initialisation list. 
" This is meant to be used into poorly-written constructors.
" How To use it:
" - Move first the '{' after the instructions you want to transform
" - Select (visual mode) the lines where the instructions are
" - Type ``:ToInitList''
" - Enjoy
" - You may have to change the leading ':' inserted into a ','.
" NB: 
" - The initialisation list is reindented at the end of the operation.
command! -buffer -range ToInitList
      \ <line1>,<line2>s#^\s*\(.\{-}\)\s*=\s*\(.\{-}\);#, \1( \2 )#
      \ |<line1>s#^,#:#
      \ |<line1>,<line2>normal! ==


command! -b -nargs=* Parents :call <sid>ShowParents(<f-args>)
 
" Commands and mappings }}}1
"=============================================================================
" Avoid global reinclusion {{{1
if exists("g:loaded_cpp_refactor") 
      \ && !exists('g:force_reload_cpp_refactor')
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_cpp_refactor = 1
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Functions {{{1

function! s:ShowParents(...)
  let classname = (a:0 == 0)
	\ ? lh#cpp#AnalysisLib_Class#CurrentScope(line('.'),'any')
	\ : a:1
  let ancestors = lh#cpp#AnalysisLib_Class#Ancestors(classname)
  echo string(ancestors)
endfunction


" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
