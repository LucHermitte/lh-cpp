"=============================================================================
" $Id$
" File:		autoload/lh/cpp/ftplugin.vim                             {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
" Created:	11th Sep 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
"       Provides lh#cpp#ftplugin#OptionalClass(...) that can be used to write
"       :commands in ftplugins that tries to deduce the name of the current
"       class if none is provided.
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Functions {{{1
" # Debug {{{2
function! lh#cpp#ftplugin#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#ftplugin#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" # Public {{{2
function! lh#cpp#ftplugin#OptionalClass(...)
  if a:0 != 0
    if     type(a:1) == type("") && strlen(a:1)>0
      return a:1
    elseif type(a:1) == type([])
      if len(a:1) > 0 && strlen(a:1[0]) > 0
	return a:1[0]
      endif
    endif
  endif

  let classname = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'),'class')
  return classname
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
