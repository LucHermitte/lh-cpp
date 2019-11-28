"=============================================================================
" File:         autoload/lh/cpp/libclang.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/blob/master/License.md>
" Version:      2.2.1.
let s:k_version = '221'
" Created:      28th Nov 2019
" Last Update:  28th Nov 2019
"------------------------------------------------------------------------
" Description:
"       Adapt results from vim-clang
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

if ! (lh#has#plugin('autoload/clang.vim') && clang#can_plugin_be_used())
  finish
endif

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#cpp#libclang#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cpp#libclang#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...) abort
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...) abort
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#cpp#libclang#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## API      functions {{{1
" # Ancestors {{{2
function! s:add_info_to_qf(qf, info, level) abort " {{{3
  let info = a:info.location
  let info.text = a:level. '+- '.a:info.access.' '.a:info.spelling
  call add(a:qf, info)
  if has_key(a:info, 'parents')
    call map(copy(a:info.parents), 's:add_info_to_qf(a:qf, v:val, "|  ".a:level)')
  endif
endfunction

" Function: lh#cpp#libclang#show_ancestors(...) {{{3
" TODO:
" - Support to pass an optional class name
" - Add option to choose qflist or loclist
function! lh#cpp#libclang#show_ancestors(...) abort
  let [parents, current] = clang#parents()
  let qf = []
  let qf += [extend(current.location, {'text': current.name})]
  call map(copy(parents), 's:add_info_to_qf(qf, v:val, "")')
  call setqflist(qf)
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
