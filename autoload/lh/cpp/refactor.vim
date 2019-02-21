"=============================================================================
" File:         autoload/lh/cpp/refactor.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/blob/master/License.md>
" Version:      2.2.1.
let s:k_version = '221'
" Created:      21st Feb 2019
" Last Update:  21st Feb 2019
"------------------------------------------------------------------------
" Description:
"       Various helpers function for refactorizing C++ code
"
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#cpp#refactor#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cpp#refactor#verbose(...)
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

function! lh#cpp#refactor#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1
" Function: lh#cpp#refactor#modernize(code) {{{3
" Things transformed:
" - typedef -> using
" - NULL -> nullptr
" - auto_ptr -> unique_ptr
function! lh#cpp#refactor#modernize(code) abort
  let code = a:code
  if lh#option#get('cpp_modernize.typedef2using', 1)
    let code = substitute(code, '\v<typedef>\_s+(\_[^;]{-})\_s+(\k+)\_s*;', 'using \2 = \1;', 'g')
  endif
  if lh#option#get('cpp_modernize.align_using', 1)
    " Correctly aligning require to use virtcol() that can only be used on
    " buffers, not on strings.
    " Fortunatelly, identifier cannot contain multi-byte characters, and the
    " only traps are tabs mixed in with spaces. In order to simplify, we will
    " suppose a size of tab &tabstop
    "
    " The objective is to align `=` signs in using directives that are identically
    " indented.
    let lines = split(code, "\n")
    " dictionary: {indent -> max col of '='}
    let maxes = {}
    function! maxes._register(line) abort
      " let suppose (for now) that tabs never follow spaces in our case...
      let indent = strlen(substitute(matchstr(a:line, '\v^\s\+'), "\t", '\=repeat(" ", &ts)', 'g'))
      let col = strlen(substitute(matchstr(a:line, '\v^\s*using\zs[^=]+'), "\t", '\=repeat(" ", &ts)', 'g'))
      if !has_key(self, indent)
        let self[indent] = col
      else
        let self[indent] = max([self[indent], col])
      endif
      return [col, indent]
    endfunction
    " 1- computes best col for '='
    let l2 = map(copy(lines), {k,v -> maxes._register(v)})
    " 2- apply it
    let offsets = map(copy(lines), {k,v -> repeat(' ', 1+l:maxes[l2[k][1]]-l2[k][0])})
    " echomsg string(offsets)
    call map(lines, {k,v -> substitute(v, '\v^\s*using\s+.{-}\zs\s+\ze\=', offsets[k], '')})
    " echomsg string(lines)
    " echomsg string(l2)
    let code = join(lines, "\n")
  endif
  if lh#option#get('cpp_modernize.nullptr', 1)
    let code = substitute(code, '\v<NULL>', 'nullptr', 'g')
  endif
  return code
endfunction

"------------------------------------------------------------------------
" ## API functions {{{1
" Function: lh#cpp#refactor#_modernize() {{{3
function! lh#cpp#refactor#_modernize() range abort
  silent let code = lh#visual#cut()
  let code = lh#cpp#refactor#modernize(code)
  silent put!=code
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
