"=============================================================================
" File:         autoload/lh/cpp/include.vim                       {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      002
" Created:      28th Apr 2014
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       «description»
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
let s:k_version = 2
function! lh#cpp#include#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#cpp#include#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#include#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" Function: lh#cpp#include#add(filename, ...) {{{3
" @return if anything was added
" usages
" - add('"filename"') 
" - add('<filename>') 
" - add('<filename>', 'first')  " ou 'last' 
" - add('filename', 0)  -> "filename"
" - add('filename', 1)  -> <filename>
" - add('filename', 0, 'first')  -> "filename"
" - add('filename', 1, 'first')  -> <filename>
function! lh#cpp#include#add(filename, ...) abort
  keepjumps normal! gg

  " Analyse arguments
  let filename0 = substitute(a:filename, '[<"]\(\f\+\)[>"]', '\1', '')
  let offset = 0
  if a:filename[0] == '<'
    let useAngleBrackets = 1
  elseif a:filename[0] == '"'
    let useAngleBrackets = 0
  elseif a:0 > 0
    let useAngleBrackets = a:1
    let offset = 1
  else
    let useAngleBrackets = 0
  endif
  if useAngleBrackets
    let filename = '<'.filename0.'>'
  else
    let filename = '"'.filename0.'"'
  endif

  let where = a:0 > offset ? a:000[offset] : 'last'

  let l = search('^#\s*include\s*["<]'.filename0.'\>', 'c')
  " todo: parameter  to inhibit this from mu-template
  if l > 0
    call lh#common#warning_msg(filename." is already included")
    return 0
  endif

  if where == "last"
    keepjumps normal! G
    let line = search('^#\s*include', 'b')
    if line == 0
      " no other #include found => like first
      return lh#cpp#include#add(filename, 'first')
    endif
  elseif where == "first"
    keepjumps normal! gg
    let line = search('^#\s*include', 'c')
    if line == 0 " try after the first #include
      " Search for the #ifndef/#define in case of include files
      let line = search('^#ifndef \(\k\+\)\>.*\n#define \1\>')
      if line > 0
        let line += 1
      elseif line('$') == 1 " empty file
        let line = 0
      else
        " Search for after the file headers
        let line = 1
        while line <= line('$')
          let ll = getline(line)
          if !lh#syntax#is_a_comment_at(line, 1) && !lh#syntax#is_a_comment_at(line, len(ll)+1) && ll !~ '^\s*\*'
            " Sometimes doxygen comments don't have a synstack
            break
          endif
          let line += 1
        endwhile
        let line -= line != line('$')
        call cursor(line, 0)
      endif
    endif
  endif
  let text='#include '.filename
  call append(line, text)
  " silent put=line
  call lh#common#warning_msg(text . ' added')
  return 1
endfunction

" Function: lh#cpp#include#add_c_std(filename, ...) {{{3
" Specialization of lh#cpp#include#add() for C standard header files <foo.h>
" that shall become <cfoo> when included from a C++ file.
function! lh#cpp#include#add_c_std(filename, ...) abort
  let ft = &ft
  let filename = (ft == 'cpp') ? ('c'.a:filename) : (a:filename.'.h')
  let filename = '<' . filename . '>'
  return call(function('lh#cpp#include#add'), [filename]+ a:000)
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
