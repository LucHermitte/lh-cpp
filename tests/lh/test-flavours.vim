"=============================================================================
" File:         tests/lh/test-flavours.vim                        {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/License.md>
" Version:      2.1.7.
let s:k_version = '217'
" Created:      23rd Nov 2015
" Last Update:09th Mar 2021
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
function! s:Setup() abort
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
function! s:Expect98() abort
  AssertEquals!(lh#cpp#get_flavour(), 03)
  Assert !lh#cpp#use_cpp11()
  Assert !lh#cpp#use_cpp14()
  Assert !lh#cpp#use_cpp17()
  Assert !lh#cpp#use_cpp20()
  Assert !lh#cpp#use_cpp23()
endfunction

function! s:Expect11() abort
  AssertEquals(lh#cpp#get_flavour(), 11)
  Assert  lh#cpp#use_cpp11()
  Assert !lh#cpp#use_cpp14()
  Assert !lh#cpp#use_cpp17()
  Assert !lh#cpp#use_cpp20()
  Assert !lh#cpp#use_cpp23()
endfunction

function! s:Expect14() abort
  AssertEquals(lh#cpp#get_flavour(), 14)
  Assert  lh#cpp#use_cpp11()
  Assert  lh#cpp#use_cpp14()
  Assert !lh#cpp#use_cpp17()
  Assert !lh#cpp#use_cpp20()
  Assert !lh#cpp#use_cpp23()
endfunction

function! s:Expect17() abort
  AssertEquals(lh#cpp#get_flavour(), 17)
  Assert  lh#cpp#use_cpp11()
  Assert  lh#cpp#use_cpp14()
  Assert  lh#cpp#use_cpp17()
  Assert !lh#cpp#use_cpp20()
  Assert !lh#cpp#use_cpp23()
endfunction

function! s:Expect20() abort
  AssertEquals(lh#cpp#get_flavour(), 20)
  Assert  lh#cpp#use_cpp11()
  Assert  lh#cpp#use_cpp14()
  Assert  lh#cpp#use_cpp17()
  Assert  lh#cpp#use_cpp20()
  Assert !lh#cpp#use_cpp23()
endfunction

function! s:Expect23() abort
  AssertEquals(lh#cpp#get_flavour(), 23)
  Assert  lh#cpp#use_cpp11()
  Assert  lh#cpp#use_cpp14()
  Assert  lh#cpp#use_cpp17()
  Assert  lh#cpp#use_cpp20()
  Assert  lh#cpp#use_cpp23()
endfunction

"------------------------------------------------------------------------
"------------------------------------------------------------------------
function! s:Test_cpp98() abort
  call s:Expect14()

  let $CXXFLAGS = '-Wall -O3 -std=c++98 -DNDEBUG'
  call s:Expect98()
endfunction

"------------------------------------------------------------------------
function! s:Test_cpp0x() abort
  let $CXXFLAGS = '-O3 -std=c++0x -Wall'
  call s:Expect11()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 14)
  call s:Expect14()
endfunction

function! s:Test_cpp11() abort
  let b:cpp_std_flavour = '11'
  call s:Expect11()
  unlet b:cpp_std_flavour

  let $CXXFLAGS = '-O3 -std=c++11 -Wall'
  call s:Expect11()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 14)
  call s:Expect14()
endfunction

"------------------------------------------------------------------------
function! s:Test_cpp1y() abort
  let $CXXFLAGS = '-O3 -std=c++1y -Wall'
  call s:Expect14()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 14)
  call s:Expect14()
endfunction

function! s:Test_cpp14() abort
  let b:cpp_std_flavour = '14'
  call s:Expect14()
  unlet b:cpp_std_flavour

  let $CXXFLAGS = '-O3 -std=c++14 -Wall'
  call s:Expect14()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 14)
  call s:Expect14()
endfunction

"------------------------------------------------------------------------
function! s:Test_cpp1z() abort
  let $CXXFLAGS = '-O3 -std=c++1z -Wall'
  call s:Expect17()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 14)
  call s:Expect14()
endfunction

function! s:Test_cpp17() abort
  let b:cpp_std_flavour = '17'
  call s:Expect17()
  unlet b:cpp_std_flavour

  let $CXXFLAGS = '-O3 -std=c++17 -Wall'
  call s:Expect17()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 14)
  call s:Expect14()
endfunction

function! s:Test_cpp2a() abort
  let $CXXFLAGS = '-O3 -std=c++2a -Wall'
  call s:Expect20()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 14)
  call s:Expect14()
endfunction

function! s:Test_cpp20() abort
  let b:cpp_std_flavour = '20'
  call s:Expect20()
  unlet b:cpp_std_flavour

  let $CXXFLAGS = '-O3 -std=c++20 -Wall'
  call s:Expect20()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 14)
  call s:Expect14()
endfunction

function! s:Test_cpp2b() abort
  let $CXXFLAGS = '-O3 -std=c++2b -Wall'
  call s:Expect23()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 14)
  call s:Expect14()
endfunction

function! s:Test_cpp23() abort
  let b:cpp_std_flavour = '23'
  call s:Expect23()
  unlet b:cpp_std_flavour

  let $CXXFLAGS = '-O3 -std=c++23 -Wall'
  call s:Expect23()

  let $CXXFLAGS = '-Wall -O3 -DNDEBUG'
  AssertEquals(lh#cpp#get_flavour(), 14)
  call s:Expect14()
endfunction

"------------------------------------------------------------------------
"------------------------------------------------------------------------
function! s:Test_prio() abort
  call s:Expect14()
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
