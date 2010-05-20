"=============================================================================
" $Id$
" File:		autoload/lh/cpp/types.vim                                 {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	10th Feb 2009
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
" 	Analysis functions for C++ types.
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	
" 	v1.1.0: Creation
" TODO:		«missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------

" ## Functions {{{1
" # Debug {{{2
function! lh#cpp#types#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#types#debug(expr)
  return eval(a:expr)
endfunction

" const correction {{{2
" Function:	s:ExtractPattern(str, pat) : str	{{{
" Note:		Internal, used by IsBaseType
function! s:ExtractPattern(expr, pattern)
  return substitute(a:expr, '^\s*\('. a:pattern .'\)\s*', '', 'g')
endfunction
" }}}
" Function:	lh#cpp#types#IsBaseType(typeName) : bool	{{{
" Note:		Do not test for aberrations like long float
function! lh#cpp#types#IsBaseType(type, pointerAsWell)
  let sign  = '\(unsigned\)\|\(signed\)'
  let size  = '\(short\)\|\(long\)\|\(long\s\+long\)\|'
  let types = '\(void\)\|\(char\)\|\(int\)\|\(float\)\|\(double\)'

  let expr = s:ExtractPattern( a:type, sign )
  let expr = s:ExtractPattern( expr,   size )
  let expr = s:ExtractPattern( expr,   types )
  if a:pointerAsWell==1
    if match( substitute(expr,'\s*','','g'), '\(\*\|&\)\+$' ) != -1
      return 1
    endif 
  endif
  " return strlen(expr) == 0
  return expr == ''
endfunction
" }}}
" Function:	lh#cpp#types#ConstCorrectType(type) : string	{{{
" Purpose:	Returns the correct expression of the type regarding the
" 		const-correctness issue ; cf Herb Sutter's
" 		_Exceptional_C++_ - Item 43.
function! lh#cpp#types#ConstCorrectType(type)
  if lh#cpp#types#IsBaseType(a:type,1) == 1
    return a:type
  else
    return 'const ' . a:type . '&'
  endif
endfunction
" }}}



"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
