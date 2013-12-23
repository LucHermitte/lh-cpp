"=============================================================================
" $Id$
" File:         autoload/lh/cpp/dox.vim                           {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
" Created:      22nd Feb 2011
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Set of functions to generate Doxygen tags in respect of the current
"       style.
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 200
function! lh#dox#_version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#dox#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#dox#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" # doxygen comment generation {{{2
" Function: lh#dox#comment_leading_char() {{{3
function! lh#dox#comment_leading_char()
  return lh#dev#option#get('dox_CommentLeadingChar', &ft, '*', 'bg')
endfunction

" Function: lh#dox#tag_leading_char() {{{3
function! lh#dox#tag_leading_char()
  return lh#dev#option#get('dox_TagLeadingChar', &ft,'@', 'bg')
  " alternative: \
endfunction

" Function: lh#dox#tag(tag) {{{3
function! lh#dox#tag(tag)
  return lh#dox#tag_leading_char().a:tag
endfunction

" Function: lh#dox#semantics(text) {{{3
" TODO: s/text/list
function! lh#dox#semantics(text)
  return '<p><b>Semantics</b><br>'
endfunction

" Function: lh#dox#throw([text]) {{{3
function! lh#dox#throw(...)
  let throw = lh#dev#option#get('dox_throw', &ft, 'throw ', 'bg')
  let res = ''
  if !empty(throw)
    let res .= lh#dox#tag(throw)
    if a:0==0 || empty(a:1) 
      let res = Marker_Txt(res)
    else
      let res .= a:1
    endif
  else
    if a:0!=0 && ! empty(a:1) 
      let res .= lh#dox#tag('throw ') . a:1
    endif
  endif
  return res
endfunction

" Function: lh#dox#ingroup([text]) {{{3
function! lh#dox#ingroup(...)
  let text = a:0==0 || empty(a:1) ? Marker_Txt('group') : a:1
  let ingroup = lh#dev#option#get('dox_ingroup', &ft, 0, 'bg')
  if     ingroup =~? '^y\%[es]$\|^a\%[lways]$\|1'
    let res =  lh#dox#tag('ingroup ').text
  elseif ingroup =~? '^no$\|^n\%[ever]$\|0'
    let res =  ''
  elseif type(ingroup) == type('')
    let res = lh#dox#tag('ingroup ').ingroup
  else " maybe
    let res = lh#marker#txt(lh#dox#tag('ingroup ').(a:0==0?'':a:1))
  endif
  return res
endfunction

" Function: lh#dox#brief([text]) {{{3
function! lh#dox#brief(...)
  let text = a:0==0 || empty(a:1) ? Marker_Txt('brief explanation').'.' : a:1
  if text[-1:] != '.' |let text .= '.' | endif
  let brief = lh#dev#option#get('dox_brief', &ft, 'short', 'bg')
  if     brief =~? '^y\%[es]$\|^a\%[lways]$\|1'
    let res =  lh#dox#tag('brief ').text
  elseif brief =~? '^no$\|^n\%[ever]$\|0\|^s\%[hort]$'
    let res =  text
  else " maybe
    let res =  Marker_Txt(lh#dox#tag('brief ')).text
  endif
  return res
endfunction

" Function: lh#dox#param({dir,name,text) {{{3
function! lh#dox#param(param)
  let res = lh#dox#tag("param")
  if type(a:param) == type({})
    if has_key(a:param, "dir") | let res .= "[".(a:param.dir)."]" | endif
    if has_key(a:param, "name") | let res .= " ".(a:param.name) | endif
    let res .= ' '. a:param.text
  else
    let res .= ' ' . a:param
  endif
  return res
endfunction

" Function: lh#dox#author() {{{3
function! lh#dox#author(...)
  let author_tag = lh#dev#option#get('dox_author_tag', &ft, 'author', 'g')
  let tag        = lh#dox#tag(author_tag) .  ' '

  let author = lh#dev#option#get('dox_author', &ft, a:0 && !empty(a:1) ? (a:1) : '', 'bg')
  if author =~ '^g:.*'
    if exists(author) 
      return tag . {author}
      " return tag . {author} . Marker_Txt('')
    else
      return tag . Marker_Txt('author-name')
    endif
  elseif strlen(author) == 0
    return tag . Marker_Txt('author-name')
  else
    return tag . author
    " return tag . author . Marker_Txt('')
  endif
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
