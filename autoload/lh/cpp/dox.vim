"=============================================================================
" $Id$
" File:         autoload/lh/cpp/dox.vim                           {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.«2»
" Created:      22nd Feb 2011
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       «description»
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh/cpp
"       Requires Vim7+
"       «install details»
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 112
function! lh#cpp#dox#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#cpp#dox#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#dox#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" # doxygen comment generation
" Function: lh#cpp#dox#comment_leading_char() {{{3
function! lh#cpp#dox#comment_leading_char()
  return lh#option#get('CppDox_CommentLeadingChar', '*', 'bg')
endfunction

" Function: lh#cpp#dox#tag_leading_char() {{{3
function! lh#cpp#dox#tag_leading_char()
  return lh#option#get('CppDox_TagLeadingChar', '@', 'bg')
  " alternative: \
endfunction

" Function: lh#cpp#dox#tag(tag) {{{3
function! lh#cpp#dox#tag(tag)
  return lh#cpp#dox#tag_leading_char().a:tag
endfunction

" Function: lh#cpp#dox#brief([text]) {{{3
function! lh#cpp#dox#brief(...)
  let text = a:0==0 ? Marker_Txt('brief').'.' : a:1
  let brief = lh#option#get('CppDox_brief', 'short', 'bg')
  if     brief =~? '^y\%[es]$\|^a\%[lways]$\|1'
    let res =  lh#cpp#dox#tag('brief ').text
  elseif brief =~? '^no$\|^n\%[ever]$\|0\|^s\%[hort]$'
    let res =  text
  else " maybe
    let res =  Marker_Txt(lh#cpp#dox#tag('brief ')).text
  endif
  return res
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
