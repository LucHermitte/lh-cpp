"=============================================================================
" File:         autoload/lh/cpp/snippets.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/License.md>
" Version:      2.1.7.
let s:k_version = '217'
" Created:      03rd Nov 2015
" Last Update:  21st Nov 2015
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
let s:k_begin_end_fmt = {
      \ 'c++98': '%1.%2()',
      \ 'std': 'std::%2(%1)',
      \ 'boost': 'boost::%2(%1)',
      \ 'adl': '%2(%1)'
      \ }

function! s:Style()
  let style = lh#dev#option#get('begin_end_style', &ft)
  if lh#option#is_unset(style)
    unlet style
    let style
          \ = lh#cpp#use_cpp11() ? 'std'
          \ :                     'c++98'
    " \ : lh#cpp#is_boost_used() ? 'boost'
  endif
  return style
endfunction

function! lh#cpp#snippets#_select_begin_end(cont, function)
  let style = s:Style()
  return lh#fmt#printf(s:k_begin_end_fmt[style], a:cont, a:function)
endfunction

let s:k_end = {
      \ 'begin'  : 'end',
      \ 'rbegin' : 'rend',
      \ 'cbegin' : 'cend',
      \ 'crbegin': 'crend'
      \ }

function! lh#cpp#snippets#_begin_end(begin) abort
  let saved_pos = getpos('.')

  if searchpair('(',',',')','bcW','lh#syntax#skip()') == 0 &&
        \ searchpair('(',',',')','bW','lh#syntax#skip()') == 0
    " Test necessary because 'c' flag and Skip() don't always work well together
    throw "Not on a parameter"
  endif
  call search('.')

  let pos = [line('.'), col('.')]
  call setpos('.', saved_pos)

  " let g:saved_pos = saved_pos
  " let g:pos = pos

  if saved_pos[1] == pos[0] && saved_pos[2] == pos[1]
    " No container under the cursor => use placeholders
    let cont = lh#marker#txt('container')
    return lh#cpp#snippets#_select_begin_end(cont, a:begin). ', ' .lh#cpp#snippets#_select_begin_end(cont, s:k_end[a:begin])
  endif

  if lh#position#char_at(saved_pos[1], saved_pos[2]-1) == ')'
    let choice = WHICH('CONFIRM', 'Do you really want to call begin() *and* end() on a function result?', "&Yes\n&No", 2)
    if choice == 'No'
      return ""
    endif
  endif

  " Let's suppose same line
  " TODO:
  " - add \s after ",", but not after "(" => use apply style on
  "   - previous.head,
  "   - and ', '.head
  "
  " Extract container name (and leading whitespace) from the two positions
  let cont = lh#position#extract(pos, saved_pos[1:2])
  " Number of characters to delete = len - nb of "\n"
  let len = lh#encoding#strlen(cont)
        \ - len(substitute(cont, "[^\n]", '', 'g'))
  " trim trailing spaces, but not those at the start
  let [all, head, cont; rest] = matchlist(cont, '\v^(\_s*)(.{-})\_s*$')
  " Build the string to "insert"
  let res = repeat("\<bs>", len)
        \ . head . lh#cpp#snippets#_select_begin_end(cont, a:begin).
        \ ', '.head .lh#cpp#snippets#_select_begin_end(cont, s:k_end[a:begin])
  if pos[0] != saved_pos[1]
    " When <bs> clear characters at the start of the line, it jumps over indent
    " => we force sw to 1
    let sw=shiftwidth()
    set sw=1
    let res .= "\<c-o>:set sw=".sw."\<cr>"
  endif
  return res
endfunction

"------------------------------------------------------------------------
" # Functions for mu-template template-files {{{2


function! lh#cpp#snippets#parents(parents) abort
  let list = []
  for parent in a:parents
    for [name, data] in items(parent)
      let list += [
            \  get(data, 'visibility', 'public') . ' '
            \ .(get(data, 'virtual', 0) ? 'virtual ' : '')
            \ .name
            \ ]
    endfor
  endfor
  let res = ''
  if !empty(list)
    if len(list) > 1
      let res = "\n"
    endif
    let res .= ': '.join(list, "\n, ")
  endif
  return res
endfunction

" Function: lh#cpp#snippets#noexcept([condition]) {{{3
function! lh#cpp#snippets#noexcept(...) abort
  let noexcept = lh#option#get('cpp_noexcept', &ft)
  let args = empty(a:000) ? '' : '('.a:1.')'
  if lh#option#is_set(noexcept)
    return lh#fmt#printf(noexcept, args)
  endif
  if lh#cpp#use_cpp11()
    return 'noexcept'.args
  else
    return 'throw()'
  endif
endfunction

" Function: lh#cpp#snippets#deleted() {{{3
function! lh#cpp#snippets#deleted() abort
  let deleted = lh#option#get('cpp_deleted', &ft)
  let args = empty(a:000) ? '' : a:1
  if lh#option#is_set(deleted)
    return deleted
  endif
  if lh#cpp#use_cpp11()
    return '= delete'
  else
    return '/* = delete */'
  endif
endfunction

" Function: lh#cpp#snippets#defaulted() {{{3
function! lh#cpp#snippets#defaulted() abort
  let defaulted = lh#dev#option#get('cpp_defaulted', &ft)
  let args = empty(a:000) ? '' : a:1
  if lh#option#is_set(defaulted)
    return defaulted
  endif
  if lh#cpp#use_cpp11()
    return '= default'
  else
    " Don't know how to default functions in C++98
    return '/* = default */'
  endif
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
