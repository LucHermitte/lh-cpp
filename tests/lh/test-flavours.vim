"=============================================================================
" File:         tests/lh/test-flavours.vim                        {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/License.md>
" Version:      2.1.7.
let s:k_version = '217'
" Created:      23rd Nov 2015
" Last Update:
"------------------------------------------------------------------------
" Description:
"       Test C++ flavour detection
"
" - Test all flavours
" - Test priorities
"------------------------------------------------------------------------
" Todo:
" - Test CMakeCache decoding
" }}}1
"=============================================================================

UTSuite [lh-cpp] Testing lh#cpp#get_flavour()

runtime autoload/lh/cpp.vim

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
function! s:Setup()
  let s:cleanup = lh#on#exit()
        \.restore_option('cpp_std_flavour')
        \.restore('$CXXFLAGS')
  silent! let $CXXFLAGS=''
  silent! unlet g:cpp_std_flavour
  silent! unlet b:cpp_std_flavour
endfunction

function! s:Teardown()
  call s:cleanup.finalize()
endfunction

"------------------------------------------------------------------------
function! s:Expect98()
  AssertEquals!(lh#cpp#get_flavour(), 03)
  Assert !lh#cpp#use_cpp11()
  Assert !lh#cpp#use_cpp14()
  Assert !lh#cpp#use_cpp17()
endfunction

function! s:Expect11()
  AssertEquals(lh#cpp#get_flavour(), 11)
  Assert  lh#cpp#use_cpp11()
  Assert !lh#cpp#use_cpp14()
  Assert !lh#cpp#use_cpp17()
endfunction

function! s:Expect14()
  AssertEquals(lh#cpp#get_flavour(), 14)
  Assert  lh#cpp#use_cpp11()
  Assert  lh#cpp#use_cpp14()
  Assert !lh#cpp#use_cpp17()
endfunction

function! s:Expect17()
  AssertEquals(lh#cpp#get_flavour(), 17)
  Assert  lh#cpp#use_cpp11()
  Assert  lh#cpp#use_cpp14()
  Assert  lh#cpp#use_cpp17()
endfunction

"------------------------------------------------------------------------
"------------------------------------------------------------------------
function! s:Test_cpp98()
  call s:Expect98()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  call s:Expect98()
endfunction

"------------------------------------------------------------------------
function! s:Test_cpp0x()
  let $CXXFLAGS = '-O3 -std=c++0x -Wall'
  call s:Expect11()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 03)
  call s:Expect98()
endfunction

function! s:Test_cpp11()
  let b:cpp_std_flavour = '11'
  call s:Expect11()
  unlet b:cpp_std_flavour

  let $CXXFLAGS = '-O3 -std=c++11 -Wall'
  call s:Expect11()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 03)
  call s:Expect98()
endfunction

"------------------------------------------------------------------------
function! s:Test_cpp1y()
  let $CXXFLAGS = '-O3 -std=c++1y -Wall'
  call s:Expect14()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 03)
  call s:Expect98()
endfunction

function! s:Test_cpp14()
  let b:cpp_std_flavour = '14'
  call s:Expect14()
  unlet b:cpp_std_flavour

  let $CXXFLAGS = '-O3 -std=c++14 -Wall'
  call s:Expect14()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 03)
  call s:Expect98()
endfunction

"------------------------------------------------------------------------
function! s:Test_cpp1z()
  let $CXXFLAGS = '-O3 -std=c++1z -Wall'
  call s:Expect17()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 03)
  call s:Expect98()
endfunction

function! s:Test_cpp17()
  let b:cpp_std_flavour = '17'
  call s:Expect17()
  unlet b:cpp_std_flavour

  let $CXXFLAGS = '-O3 -std=c++17 -Wall'
  call s:Expect17()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 03)
  call s:Expect98()
endfunction

"------------------------------------------------------------------------
"------------------------------------------------------------------------
function! s:Test_prio()
  call s:Expect98()
  let $CXXFLAGS = '-O3 -std=c++17 -Wall'
  call s:Expect17()
  let g:cpp_std_flavour = '11'
  call s:Expect11()
  let b:cpp_std_flavour = '03'
  call s:Expect98()
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
