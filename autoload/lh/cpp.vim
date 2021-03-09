"=============================================================================
" File:         autoload/lh/cpp.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/License.md>
" Version:      2.2.1
let s:k_version = '221'
" Created:      08th Jun 2014
" Last Update:  09th Mar 2021
"------------------------------------------------------------------------
" Description:
"       Various C++ related functions
"
" - C++ flavour detection
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#cpp#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#cpp#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" # Obtain C++ flavour (03, TR1, 11, 14, 17, 20) {{{2
" @note this set of functions deprecates lh#dev#cpp#use_cpp11()

" Function: lh#cpp#get_flavour() {{{3
" @return a value among: 03 (C++98/03), 05 (TR1), 11 (C++11), 14, 17, 20
function! lh#cpp#get_flavour()
  " First check a dedicated set of variables
  let flavour = lh#option#get('cpp_std_flavour', 0)
  if flavour != 0 | return flavour | endif

  let flavour = s:CheckFlavour()
  if flavour != 0 | return flavour | endif

  " then, check $CXXFLAGS
  if exists('$CXXFLAGS')
    let std=matchstr($CXXFLAGS, '-std=\zs\S\+\ze')
    if !empty(std)
      return s:DecodeStdFlavour(std)
    endif
  endif

  " Or CMAKE CXXFLAGS
  let flags = ''
  try
    " The following may fail if lh-cmake is not installed
    " or if the project isn't using CMake
    let flags = lh#cmake#get_variables('CXXFLAGS')
  catch /.*/
  endtry
  " Or compile_commands.json database
  " as newer versions of CMake use the CXX_STANDARD property that
  " doesn't set any variable that can be fetched.
  if empty(flags)
    try
      " The following may fail if build-tools-wrapper is not installed
      " or if the project isn't using CMake
      let prj_dirname = lh#project#_check_project_variables(
        \ ['paths.sources', 'project_sources_dir', ['BTW_project_config', '_.paths.sources']])
      let dbs = lh#path#glob_as_list(
            \ [lh#btw#compilation_dir(), prj_dirname],
            \ 'compile_commands.json', 0)
      if  !empty(dbs)
        let db = dbs[0]
        let l_flags = filter(readfile(db), 'v:val =~ "-std="')
        let flags = empty(l_flags) ? '' : l_flags[0]
      endif
    catch /.*/
    endtry
  endif

  " And ... decode!
  if !empty(flags)
    let std=matchstr(flags, '-std=\zs\S\+\ze')
    if !empty(std)
      return s:DecodeStdFlavour(std)
    endif
  endif

  return 14
endfunction

" Function: lh#cpp#use_TR1() {{{3
function! lh#cpp#use_TR1(...)
  let flavour = lh#cpp#get_flavour()
  return flavour == 05
endfunction

" Function: lh#cpp#use_cpp11([and_no_more = 0]) {{{3
function! lh#cpp#use_cpp11(...)
  let flavour = lh#cpp#get_flavour()
  if a:0 == 0 || a:1 == 0
    return flavour >= 11
  else
    return flavour == 11
  endif
endfunction

" Function: lh#cpp#use_cpp14([and_no_more = 0]) {{{3
function! lh#cpp#use_cpp14(...)
  let flavour = lh#cpp#get_flavour()
  if a:0 == 0 || a:1 == 0
    return flavour >= 14
  else
    return flavour == 14
  endif
endfunction

" Function: lh#cpp#use_cpp17([and_no_more = 0]) {{{3
function! lh#cpp#use_cpp17(...)
  let flavour = lh#cpp#get_flavour()
  if a:0 == 0 || a:1 == 0
    return flavour >= 17
  else
    return flavour == 17
  endif
endfunction

" Function: lh#cpp#use_cpp20([and_no_more = 0]) {{{3
function! lh#cpp#use_cpp20(...)
  let flavour = lh#cpp#get_flavour()
  if a:0 == 0 || a:1 == 0
    return flavour >= 20
  else
    return flavour == 20
  endif
endfunction

" Function: lh#cpp#use_cpp23([and_no_more = 0]) {{{3
function! lh#cpp#use_cpp23(...)
  let flavour = lh#cpp#get_flavour()
  if a:0 == 0 || a:1 == 0
    return flavour >= 23
  else
    return flavour == 23
  endif
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

" # C++ flavour
" Function: s:CheckFlavour() {{{3
function! s:CheckFlavour()
  if lh#option#get('cpp_use_TR1', 0) | return 05 | endif
  let flavours = {
        \ 'cpp03': 03,
        \ 'cpp05': 05,
        \ 'cpp11': 11,
        \ 'cpp14': 14,
        \ 'cpp17': 17,
        \ 'cpp20': 20
        \ 'cpp23': 23
        \ 'cpp26': 26
        \ }
  " TODO: use filter!
  for kv in reverse(items(flavours))
    if lh#option#get('cpp_use_'.kv[0], 0)
      return kv[1]
    endif
  endfor
  return 0
endfunction

" Function: s:DecodeStdFlavour(std) {{{3
function! s:DecodeStdFlavour(std)
  let std = matchstr(a:std, '\(gnu++\|c++\)\zs.*')
  if     std =~ '\(98\|03\)' | return 03
  elseif std =~ '\(11\|0x\)' | return 11
  elseif std =~ '\(14\|1y\)' | return 14
  elseif std =~ '\(17\|1z\)' | return 17
  elseif std =~ '\(20\|2a\)' | return 20
  elseif std =~ '\(23\|2b\)' | return 23
  elseif std =~ '\(26\|2c\)' | return 26
  else                       | return 03
  endif
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
