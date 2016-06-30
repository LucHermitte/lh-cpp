"=============================================================================
" File:         autoload/lh/cpp/understand.vim                    {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.0.
let s:k_version = '220'
" Created:      30th Jun 2016
" Last Update:  30th Jun 2016
"------------------------------------------------------------------------
" Description:
"   Plugin that imports understand csv to browse codecheck results.
"
" Format expected:
"   file:line:col: check ; check msg; check detail; other things
"   Note this is not the default output format: you'll have to change a few
"   semi-colons into colons.
"
" Usage:
"   (draft version that needs to be enhanced)
"   Load the .csv with:
"       :let u = lh#cpp#understand#init('checks.csv')
"   Choose which violations shall be displayed:
"       :call u.filter(['6-4-5', 'Unused Variables'], 'check')
"   Navigate the violations presented into the quickfix window:
"       :h :cn / :h :cp / :h quickfix
"
"------------------------------------------------------------------------
" TODO:
" - define commands to add some ergonomy into these functions
" - read a real .csv file
" - Extract the qf filtering functions to lh-vim-lib
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#cpp#understand#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cpp#understand#verbose(...)
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

function! lh#cpp#understand#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" Function: lh#cpp#understand#init(cvs_file) {{{2
function! lh#cpp#understand#init(cvs_file) abort
  let d = {}
  " This way all bufnr are defined
  exe 'cgetfile ' . a:csv_file
  let d.data = getqflist()

  let d.data = map(d.data, 's:analyse_violation(v:val)')

  let d.checks    = lh#list#possible_values(d.data, 'check')
  let d.filenames = lh#list#possible_values(d.data, 'filename')

  let d.filter = function('s:filter')

  return d
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

" Function: s:violation_list2dict(v) {{{2
function! s:violation_list2dict(v)
  return
        \ { 'filename': a:v[1]
        \ , 'lnum'    : a:v[2]
        \ , 'col'     : a:v[3]
        \ , 'check'   : a:v[4]
        \ , 'results' : a:v[5]
        \ , 'entity'  : a:v[6]
        \ , 'rem'     : a:v[7]
        \ , 'text'    : join(a:v[4:], ';')
        \ }
endfunction

" Function: s:filter(elements, what) dict abort {{{2
function! s:filter(elements, what) dict abort
  let regex = '\v'.join(map(copy(a:elements), 'escape(v:val, "\\\\()<>{}+=")'), '|')
  let res = filter(copy(self.data), 'v:val[a:what] =~ regex')
  call setqflist(res)
  return res
endfunction

" Function: s:analyse_violation(v) {{{2
function! s:analyse_violation(v) abort
  let v = a:v
  let infos = split(v.text, ';')
  let v.check   = infos[0]
  let v.results = infos[1]
  let infos[1] = substitute(infos[1], '\v^"\s*(.*)\s*"$', '\1', '')
  let infos[1] = substitute(infos[1], '""""', '"', 'g')
  let v.results = infos[1]
  let v.entity  = infos[2]
  " let v.pattern = v.entity
  let v.rem     = infos[3:]
  let v.filename = bufname(v.bufnr)

  let v.text = join(infos, ' ; ')
  return v
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
