"=============================================================================
" File:         autoload/lh/cpp.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/License.md>
" Version:      2.1.7
let s:k_version = '217'
" Created:      08th Jun 2014
" Last Update:  23rd Nov 2015
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

" # Obtain C++ flavour (03, TR1, 11, 14, 17) {{{2
" @note this set of functions deprecates lh#dev#cpp#use_cpp11()

" Function: lh#cpp#get_flavour() {{{3
" @return a value among: 03 (C++98/03), 05 (TR1), 11 (C++11), 14, 17
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
  if !empty(flags)
    let std=matchstr(flags, '-std=\zs\S\+\zs')
    if !empty(std)
      return s:DecodeStdFlavour(std)
    endif
  endif

  return 03
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
        \ 'cpp17': 17
        \ }
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
  else                       | return 03
  endif
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
