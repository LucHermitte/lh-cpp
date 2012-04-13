"=============================================================================
" $Id$
" File:		autoload/lh/cpp/style.vim                                 {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
" Created:	10th Feb 2009
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
" 	General coding style functions
" 
"------------------------------------------------------------------------
" History:	
" 	v1.1.0: Creation
"	v2.0.0: License GPLv3 w/ extension
" TODO:		
" 	- Refactor to build on top of lh#dev
" 	- Integrate style preferences used by InsertAccessors
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------

" ## Functions {{{1
" # Debug {{{2
function! lh#cpp#style#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#style#debug(expr)
  return eval(a:expr)
endfunction

" # Style accessors {{{2
function! lh#cpp#style#get(datakind, pos)
  let value = lh#option#get(a:datakind.a:pos, '')
  return value
endfunction

" # Names conversion {{{2
" Function: lh#cpp#style#attribute2parameter_name(attrb_name) {{{3
function! lh#cpp#style#attribute2parameter_name(attrb_name)
  let core_name = substitute(a:attrb_name,
	\ lh#cpp#style#get('data','Prefix')
	\ .'\(.*\)'.
	\ lh#cpp#style#get('data','Suffix')
	\ , '\1', 'g')
  let param_name =
	\ lh#cpp#style#get('param','Prefix')
	\ . core_name .
	\ lh#cpp#style#get('param','Suffix')
  if param_name == a:attrb_name
    let param_name = Marker_Txt(param_name)
  endif
  return param_name
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
