"=============================================================================
" File:         autoload/lh/cpp/scope.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      2.0.0b10
" Created:      25th Jun 2014
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Support autoload plugin for ftplugin/cpp/cpp_AddMissingScope.vim
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 200
function! lh#cpp#scope#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#cpp#scope#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#scope#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## API functions {{{1
" Function: lh#cpp#scope#_add_missing() {{{3
function! lh#cpp#scope#_add_missing() abort
  let [id, info] = lh#cpp#tags#fetch("add-missing-scope")
  try 

    " Filter out constructors
    let isk_save = &isk
    set isk-=:
    call filter(info, "! (v:val.kind =~ 'f' && v:val.name=~'.*\\<\\(\\k\\+\\)::\\1')")

    " Build the list of names
    let names = {}
    for t in info
      if ! has_key(names, t.name)
        let names[t.name] = {}
      endif
      let names[t.name][t.kind[0]] = ''
    endfor

    " Check the number of possible choices
    if len(info) > 1
      call lh#common#error_msg("add-missing-scope: too many acceptable tags for `"
            \ .id."': ".string(names))
      return
    endif

    let name = keys(names)[0]

    if name == id
      call lh#common#warning_msg("add-missing-scope: `".id."' is already expanded")
      return
    endif

    " build the new line
    set isk+=:
    let line = getline('.')
    let head = matchstr(line[:col('.')-1], '.*\ze\<\k\+$')
    let tail = line[lh#encoding#strlen(head):]
    let missing = matchstr(name, '.*\ze'.id)
    call setline(line('.'), head.missing.tail)
  finally
    let &isk = isk_save
  endtry
endfunction
"------------------------------------------------------------------------
" ## Exported functions {{{1

"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
