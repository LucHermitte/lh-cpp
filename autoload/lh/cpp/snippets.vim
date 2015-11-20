"=============================================================================
" File:         autoload/lh/cpp/snippets.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/License.md>
" Version:      2.1.6.
let s:k_version = '216'
" Created:      03rd Nov 2015
" Last Update:  06th Nov 2015
"------------------------------------------------------------------------
" Description:
"       Tool functions to help write snippets (ftplugin/c/c_snippets.vim)
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#cpp#snippets#version()
  return s:k_version
endfunction

" # Debug   {{{2
if !exists('s:verbose')
  let s:verbose = 0
endif
function! lh#cpp#snippets#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#snippets#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1
" # snippets functions {{{2
" Function: lh#cpp#snippets#def_abbr(key, expr) {{{3
function! lh#cpp#snippets#def_abbr(key, expr) abort
  if getline('.') =~ '^\s*#'
    return a:key
  endif
  " Default behaviour
  let rhs = lh#dev#style#apply(a:expr)
  return lh#map#insert_seq(a:key, rhs)
endfunction

" Function: lh#cpp#snippets#def_map(key, expr1, expr2) {{{3
function! lh#cpp#snippets#def_map(key, expr1, expr2) abort
  if lh#brackets#usemarks()
    return "\<c-r>=lh#map#no_context2('".a:key."',lh#map#build_map_seq('".a:expr2."'))\<cr>"
  else
    return "\<c-r>=lh#map#no_context2('".a:key."', '".a:expr1."')\<cr>"
  endif
endfunction

" Function: lh#cpp#snippets#insert_return() {{{3
function! lh#cpp#snippets#insert_return() abort
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, c)
  if l =~ '^\s*$'
    return lh#map#build_map_seq('return ;!mark!\<esc\>==0:call lh#cpp#snippets#_goto_return_semicolon()\<cr\>i')
  else
    let spacesLen = strlen(matchstr(l, '^\s*'))
    let stripCmd = (spacesLen!=0) ? '\<esc\>'.'ct'.l[spacesLen] : ''
    echo stripCmd
    if stridx(l, ';') != -1
      return lh#map#build_map_seq(stripCmd.'return \<esc\>==0:call lh#cpp#snippets#_goto_return_semicolon()\<cr\>a')
    elseif stridx(l, '}') != -1
      return lh#map#build_map_seq(stripCmd.'return ;!mark!\<esc\>==0:call lh#cpp#snippets#_goto_return_semicolon()\<cr\>i')
    else
      return lh#map#build_map_seq(stripCmd.'return \<esc\>==A;')
    endif
  endif
endfunction

" Function: lh#cpp#snippets#insert_if_not_after(key, what, pattern) {{{3
function! lh#cpp#snippets#insert_if_not_after(key, what, pattern) abort
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, 0, c)
  if l =~ a:pattern.'\s*$'
    return a:key
  else
    return lh#cpp#snippets#def_abbr(a:key, a:what)
  endif
endfunction

" Function: lh#cpp#snippets#insert_if_not_before(key, what, pattern) {{{3
function! lh#cpp#snippets#insert_if_not_before(key, what, pattern) abort
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, c)
  if l =~ '^\s*'.a:pattern
    return a:key
  else
    return lh#cpp#snippets#def_abbr(a:key, a:what)
  endif
endfunction

" Function: lh#cpp#snippets#typedef_typename() {{{3
function! lh#cpp#snippets#typedef_typename() abort
  return lh#cpp#snippets#insert_if_not_after('typename ', 'typedef ', 'typedef\|<\|,')
endfunction

" Function: lh#cpp#snippets#current_namespace(default) {{{3
function! lh#cpp#snippets#current_namespace(default) abort
  let ns = lh#dev#option#get('project_namespace', &ft, '')
  return empty(ns) ? a:default : (ns.'::')
endfunction

" Function: lh#cpp#snippets#select_expr_4_surrounding() {{{3
function! lh#cpp#snippets#select_expr_4_surrounding() abort
  " Go to the first non blank character of the line
  :normal! ^
  " Search either the first semin-colon or the end of the line.
  :call search(';\|\s*$', 'c')
  " If we are not at the end of the line
  if getline('.')[col('.')-1] =~ ';\|\s'
    " If it is followed by blanck characters
    if strpart(getline('.'), col('.')) =~ '^\s*$'
      " then trim the ';' (or the space) and every thing after
      exe "normal! \"_d$"
    else
      " otherwise replace the ';' by a newline character, and goto the end of
      " the previous line (where the line has been cut)
      exe "normal! \"_s\n\<esc>k$"
    endif
  endif
  " And then select till the first non blank character of the line
  :normal! v^
endfunction

" Function: lh#cpp#snippets#begin_end() {{{3
" In std::foreach and std::find algorithms, ..., expand 'algo(container§)'
" into:
" - 'algo(container.begin(),container.end()§)',
" - 'algo(container.rbegin(),container.rend()§)',
" - 'algo(container.cbegin(),container.cend()§)',
" - 'algo(begin.(container),end.(container)§)',
" - 'algo(rbegin.(container),rend.(container)§)',
" - 'algo(cbegin.(container),cend.(container)§)',
"
" Objectives: support redo/repeat
function! s:BeginEnd(cont, function)
  return printf('%s.%s()', a:cont, a:function)
endfunction

let s:k_end = {
      \ 'begin'  : 'end',
      \ 'rbegin' : 'rend',
      \ 'cbegin' : 'cend',
      \ 'crbegin': 'crend'
      \ }

function! lh#cpp#snippets#_begin_end(begin) abort
  let saved_pos = getpos('.')
  let pos = searchpos('[,()]', 'bnW')
  if pos == [0,0]
    throw "Not within a function call"
  endif

  let g:saved_pos = saved_pos
  let g:pos = pos

  if saved_pos[1] == pos[0] && saved_pos[2] == pos[1]+1
    if lh#position#char_at(pos[0], pos[1]) == ')'
      throw "Do you really want to call begin/end on function results! (".string(pos).")"
    endif
    " No container under the cursor => use placeholders
    let cont = lh#marker#txt('container')
    return s:BeginEnd(cont, a:begin). ', ' .s:BeginEnd(cont, s:k_end[a:begin])
  endif

  " Let's suppose same line
  " TODO: handle "\_s*"
  if saved_pos[1] == pos[0]
    let cont = getline(pos[0])[pos[1] : (saved_pos[2]-2)]
    let len = lh#encoding#strlen(cont)
    let res = repeat("\<bs>", len) . s:BeginEnd(cont, a:begin). ', ' .s:BeginEnd(cont, s:k_end[a:begin])
    return res
  endif

  throw "Unexpected case"
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

" # snippet functions {{{2
" Function: lh#cpp#snippets#_goto_return_semicolon() {{{3
function! lh#cpp#snippets#_goto_return_semicolon() abort
  let p = getpos('.')
  let r = search('return.*;', 'e')
  if r == 0 | call setpos('.', p) | endif
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
