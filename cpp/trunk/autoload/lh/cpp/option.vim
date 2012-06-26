"=============================================================================
" $Id$
" File:         autoload/lh/cpp/option.vim                        {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      200
" Created:      05th Apr 2012
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Options for lh-cpp 
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh/cpp
"       Requires Vim7+, lh-dev
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 1
function! lh#cpp#option#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#cpp#option#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#option#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" # Preferences regarding how control statements are expanded {{{2
" Possible values: 0 (default)/1
" Applies to: if (){}, else{}, for (;;){}, while(){}, switch, catch, ...

" Function: lh#cpp#option#nl_before_bracket() {{{3
" Write each '(' on a new line; -> if \n() ... {}
function! lh#cpp#option#nl_before_bracket()
  return lh#dev#option#get('nl_before_bracket', &ft, 0)
endfunction

" Function: lh#cpp#option#nl_before_curlyB() {{{3
" Write each '{' on a new line; -> if ...() \n {}
function! lh#cpp#option#nl_before_curlyB()
  return lh#dev#option#get('nl_before_curlyB', &ft, 0)
endfunction

" Function: lh#cpp#option#multiple_namespace_on_same_line() {{{3
" Write each "namespace Foo {" on a same line
function! lh#cpp#option#multiple_namespaces_on_same_line()
  return lh#dev#option#get('multiple_namespaces_on_same_line', &ft, 1)
endfunction
"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
