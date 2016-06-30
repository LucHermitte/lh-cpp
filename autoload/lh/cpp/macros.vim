"=============================================================================
" File:         autoload/lh/cpp/macros.vim                        {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.0.
let s:k_version = '220'
" Created:      30th Jun 2016
" Last Update:  30th Jun 2016
"------------------------------------------------------------------------
" Description:
"       API related to C and C++ macros
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
function! lh#cpp#macros#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cpp#macros#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...)
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...)
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#cpp#macros#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" # Clean `#if`
" Function: lh#cpp#macros#keep(bool) {{{3
" Remove the true/false path into a `#if ... #else ... #endif` construct
" TODO: support `defined(...)`, `#elif`, ...
function! lh#cpp#macros#keep(bool) abort
  " 0- Requirements
  " 0.1- Check matchit is installed
  if !exists('g:loaded_matchit')
    runtime macros/matchit.vim
    if !exists('g:loaded_matchit')
      throw 'Cannot trim `#if..#else..#endif` path without matchit'
    endif
  endif
  " 0.2- Be sure we're on the `#if 0/1` line
  let line = getline('.')
  if line !~ '\v^#\s*if\s+[01]'
    throw 'Cursor not on a `#if 0|1` line. Cannot trim paths.'
  endif

  " 1- Note line numbers
  normal! ^
  let l_if = line('.')
  normal %
  let l = line('.')
  if getline(l) =~ '\v^#\s*else'
    let l_else = l
    normal %
    let l = line('.')
  endif " Not an elif here!
  if getline(l) !~ '\v^#\s*endif'
    throw '`#endif` expected (`#elif` is not supported yet)'
  endif
  let l_endif = line('.')

  " 2- Trim (starting from the end)
  let keep_start = (line =~ '\v^#\s*if\s+1') == eval(a:bool)
  let l_last_if    = keep_start ? l_if : l_else
  let l_first_else = keep_start ? l_else : l_endif
  call s:Verbose('Keeping the `#%1` case -- :%2,%3d | %4,%5d', keep_start ? 'if' : 'else', l_first_else, l_endif, l_if, l_last_if)
  silent! exe l_first_else.','.l_endif.'d _'
  silent! exe l_if.','.l_last_if.'d _'
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
