"=============================================================================
" File:         autoload/lh/cpp/libclang.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/blob/master/License.md>
" Version:      2.2.1.
let s:k_version = '221'
" Created:      28th Nov 2019
" Last Update:  10th Jan 2020
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

let s:k_has_compil_hints = lh#has#plugin('autoload/lh/compil_hints.vim')
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
function! s:add_info_to_qf(qf, balloons, info, level, balloon_ctx) abort " {{{3
  let info = a:info.location
  let info.text = a:level. '+- '.a:info.access.' '.a:info.spelling
  call add(a:qf, info)
  let balloon_ctx = ' : '.a:info.access.' '.a:info.spelling . a:balloon_ctx
  call add(a:balloons, balloon_ctx)
  if has_key(a:info, 'parents')
    call map(copy(a:info.parents), 's:add_info_to_qf(a:qf, a:balloons, v:val, a:level."|  ", balloon_ctx)')
  endif
endfunction

" Function: lh#cpp#libclang#show_ancestors(...) {{{3
" TODO:
" - Support to pass an optional class name
" - Add option to choose qflist or loclist
function! lh#cpp#libclang#show_ancestors(...) abort
  let [parents, current] = clang#parents()
  let qf = []
  let qf += [extend(current.location, {'text': "~\t" . current.name})]
  let balloons = [' : inspected leaf']
  call map(copy(parents), 's:add_info_to_qf(qf, balloons, v:val, "~\t", "")')
  let max_length = max(map(copy(qf), {k,v -> strdisplaywidth(v.filename)}))
  call setqflist(qf)
  if lh#has#properties_in_qf()
    call setqflist([], 'a', {'title': current.name . ' base classes'})
    if s:k_has_compil_hints
      call lh#compil_hints#set_balloon_format({k, v -> l:current.name . l:balloons[v.key]})
    endif
  endif
  if exists(':Copen')
    Copen
  else
    copen
  endif
  let qf_winnr = lh#qf#get_winnr()
  if qf_winnr > 0
    let qf_bufnr = winbufnr(qf_winnr)
    call setbufvar(qf_bufnr, '&tabstop', max_length+15)
  endif
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
