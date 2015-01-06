"=============================================================================
" $Id$
" File:         autoload/lh/cpp/tags.vim                          {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      2.0.0b14
" Created:      25th Jun 2014
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       API functions to obtain symbol declarations
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 200
function! lh#cpp#tags#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#cpp#tags#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#tags#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1
" Function: lh#cpp#tags#strip_included_paths(filename, includes) {{{3
function! lh#cpp#tags#strip_included_paths(filename, includes)
  let filename = a:filename
  if !empty(a:includes)
    if filename[0] == '/' " absolute => try to remove things from b:includes and/or b:sources_root
      let filename = lh#path#strip_start(filename, a:includes)
    endif
  else
    let filename_simplify = lh#dev#option#get('filename_simplify_for_inclusion', &ft, ':t')
    let filename = fnamemodify(filename, filename_simplify)
  endif
  return filename
endfunction

" Function: lh#cpp#tags#get_included_paths() {{{3
function! lh#cpp#tags#get_included_paths()
  let includes = []
  if exists('b:sources_root') " from mu-template & lh-suite(s)
    let includes += [lh#path#to_dirname(b:sources_root)]
  endif
  if exists('b:includes')
    let includes += b:includes
  endif
  return includes
endfunction

" Function: lh#cpp#tags#fetch(feature) {{{3
function! lh#cpp#tags#fetch(feature) abort
  let id = eval(s:TagsSelectPolicy())

  try
    let isk_save = &isk
    set isk-=:
    let info = taglist('.*\<'.id.'$')
  finally
    let &isk = isk_save
  endtry
  if len(info) == 0
    throw a:feature.": no tags for `".id."'"
  endif
  " Filter for function definitions and #defines, ...
  let accepted_kinds = lh#dev#option#get('tag_kinds_for_inclusion', &ft, '[dfptcs]')
  call filter(info, "v:val.kind =~ ".string(accepted_kinds))
  " Filter for include files only
  let accepted_files = lh#dev#option#get('file_regex_for_inclusion', &ft, '\.h')
  call filter(info, "v:val.filename =~? ".string(accepted_files))
  " Is there any symbol left ?
  if len(info) == 0
    throw a:feature.": no acceptable tag for `".id."'"
  endif

  " Strip the leading path that won't ever appear in included filename
  let includes = lh#cpp#tags#get_included_paths()
  for val in info
    let val.filename = lh#cpp#tags#strip_included_paths(val.filename, includes)
  endfor
  " call map(info, "v:val.filename = lh#cpp#tags#strip_included_paths(v:val.filename, includes)")

  " And remove redundant info
  let info = lh#tags#uniq_sort(info)
  return [id, info]
endfunction
"------------------------------------------------------------------------
" ## Internal functions {{{1
function! s:TagsSelectPolicy()
  let select_policy = lh#option#get('tags_select', "expand('<cword>')", 'bg')
  return select_policy
endfunction


"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
