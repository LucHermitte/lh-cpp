"=============================================================================
" File:         autoload/lh/cpp/tags.vim                          {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      2.3.0
let s:k_version = 230
" Created:      25th Jun 2014
" Last Update:  24th Oct 2018
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
function! lh#cpp#tags#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cpp#tags#verbose(...)
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

function! lh#cpp#tags#debug(expr) abort
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Exported functions {{{1

" Function: lh#cpp#tags#find_compiler() {{{3
" Let's assume C++ and not C
" TODO: support C
function! lh#cpp#tags#find_compiler() abort
  runtime autoload/lh/cmake.vim
  if exists('*lh#cmake#get_variables')
    try
      let compiler = lh#cmake#get_variables('CMAKE_CXX_COMPILER').CMAKE_CXX_COMPILER.value
      return compiler
    catch /.*/
      " The project isn't under CMake
    endtry
  endif
  if exists('$CXX')
    return $CXX
  elseif executable('c++')
    return 'c++'
  elseif executable('g++')
    return 'g++'
  elseif executable('clang++')
    return 'clang++'
  endif
endfunction

" Function: lh#cpp#tags#compiler_includes() {{{3
" Fetch standard includes (hard coded in the compiler)
" TODO: find a way to support intel compiler
let s:compiler_includes = {}
function! lh#cpp#tags#compiler_includes() abort
  let compiler = lh#cpp#tags#find_compiler()
  if ! has_key(s:compiler_includes, compiler)
    " Let's assume a *nix compiler (g++, clang++)
    let includes = split(lh#os#system(compiler . ' -E -xc++ - -Wp,-v < /dev/null'), "\n")
    call filter(includes, 'v:val =~ "^ "')
    call map(includes, 'lh#path#simplify(v:val[1 :])')
    " Note that it should contain /usr/include & all
    let s:compiler_includes[compiler] = includes
  endif
  return s:compiler_includes[compiler]
endfunction

" Function: lh#cpp#tags#strip_included_paths(filename, includes) {{{3
function! lh#cpp#tags#strip_included_paths(filename, includes)
  let filename = a:filename
  if !empty(a:includes)
    if filename[0] == '/' " absolute => try to remove things from b:includes and/or b:sources_root
      let filename = lh#path#strip_start(filename, a:includes)
    endif
  else
    let filename_simplify = lh#ft#option#get('filename_simplify_for_inclusion', &ft, ':t')
    let filename = fnamemodify(filename, filename_simplify)
  endif
  return filename
endfunction

" Function: lh#cpp#tags#get_included_paths([default]) {{{3
function! s:as_list(p) abort
  return type(a:p) == type([]) ? a:p : [a:p]
endfunction

function! lh#cpp#tags#get_included_paths(...)
  let includes = []
  " sources_root: from mu-template & lh-suite(s)
  " paths.sources: from lh#project
  let sources_root = lh#option#get(['sources_root', 'paths.sources'])
  if lh#option#is_set(sources_root)
    let includes += [lh#path#to_dirname(sources_root)]
  endif
  " paths.includes: new paths from lh#project
  " includes: old path
  let def_includes = lh#option#get(['paths.includes', 'includes'])
  if lh#option#is_set(def_includes)
    call map(copy(def_includes), 'extend(includes, s:as_list(type(v:val)==type(function("has")) ? call(v:val,[]) : v:val))')
    call filter(includes, '!empty(v:val)')
  elseif a:0 > 0
    let includes += type(a:1) == type([]) ? a:1 : split(a:1, ',')
  endif
  return lh#list#unique_sort(includes)
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
  let accepted_kinds = lh#ft#option#get('tag_kinds_for_inclusion', &ft, '[dfptcs]')
  call filter(info, "v:val.kind =~ ".string(accepted_kinds))
  " Filter for include files only
  let accepted_files = lh#ft#option#get('file_regex_for_inclusion', &ft, '\.h')
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

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
