"=============================================================================
" File:         tests/lh/test-types.vim                           {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.0.
let s:k_version = '220'
" Created:      15th Dec 2015
" Last Update:  15th Dec 2015
"------------------------------------------------------------------------
" Description:
"       Test lh#cpp#types#...
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

UTSuite [lh-cpp] Testing lh/cpp/types.vim

runtime autoload/lh/cpp/types.vim

let s:cpo_save=&cpo
set cpo&vim


" SetUp {{{1
" Function: s:Setup() {{{3
function! s:Setup() abort
  " SetMarker <+ +>
  " it seems that playing with encodings messes vim execution through rspec
  let b:marker_open = '<+'
  let b:marker_close = '+>'
  let b:last_encoding_used = &enc
  AssertEquals( b:marker_open, '<+')
  AssertRelation( lh#marker#version(), '>=' , 310)
  AssertEquals(lh#marker#open(), '<+')
endfunction

" Tests {{{1
"------------------------------------------------------------------------
function! s:Test_none() " {{{2
  let info = lh#cpp#types#get_info('invalid_type')
  Assert get(info, 'unknown', 0)

  AssertEquals(lh#cpp#types#get_includes('<invalid_type>'), [])
endfunction

"------------------------------------------------------------------------
function! s:Test_vector() " {{{2
  let vector = lh#cpp#types#get_info('vector')
  AssertEquals(vector.includes                 , ['<vector>'])
  AssertEquals(vector.name                    , 'vector')
  AssertEquals(vector.type                    , 'vector<%1>')
  AssertEquals(vector.namespace               , 'std')
  AssertEquals(vector.typename_for_header('T'), 'std::vector<T>')
  AssertEquals(vector.typename_for_header()   , 'std::vector<<+T1+>>')
endfunction

"------------------------------------------------------------------------
function! s:Test_map() " {{{2
  let map = lh#cpp#types#get_info('map')
  AssertEquals(map.includes                      , ['<map>'])
  AssertEquals(map.name                         , 'map')
  AssertEquals(map.type                         , 'map<%1,%2>')
  AssertEquals(map.namespace                    , 'std')
  AssertEquals(map.typename_for_header('T', 'V'), 'std::map<T,V>')
  AssertEquals(map.typename_for_header('T')     , 'std::map<T,<+T2+>>')
  AssertEquals(map.typename_for_header()        , 'std::map<<+T1+>,<+T2+>>')
endfunction

"------------------------------------------------------------------------
function! s:Test_string() " {{{2
  let string = lh#cpp#types#get_info('string')
  AssertEquals(string.includes              , ['<string>'])
  AssertEquals(string.name                 , 'string')
  AssertEquals(string.type                 , 'string')
  AssertEquals(string.namespace            , 'std')
  AssertEquals(string.typename_for_header(), 'std::string')
endfunction

"------------------------------------------------------------------------
function! s:Test_chrono() " {{{2
  let chrono_time_point = lh#cpp#types#get_info('chrono::time_point')
  AssertEquals(chrono_time_point.includes  , ['<chrono>'])
  AssertEquals(chrono_time_point.name     , 'chrono::time_point')
  AssertEquals(chrono_time_point.type     , 'chrono::time_point<%1>')
  AssertEquals(chrono_time_point.namespace, 'std')
endfunction

"------------------------------------------------------------------------
function! s:Test_size_t() " {{{2
  let size_t = lh#cpp#types#get_info('size_t')
  AssertEquals(size_t.includes  , ['<cstddef>', '<cstdio>', '<cstring>', '<ctime>', '<cstdlib>', '<cwchar>'])
  AssertEquals(size_t.name     , 'size_t')
  AssertEquals(size_t.type     , 'size_t')
  AssertEquals(size_t.namespace, 'std')
endfunction

"------------------------------------------------------------------------
function! s:Test_noncopyable() " {{{2
  let noncopyable = lh#cpp#types#get_info('noncopyable')
  AssertEquals(noncopyable.includes  , ['<boost/noncopyable.hpp>'])
  AssertEquals(noncopyable.name     , 'noncopyable')
  AssertEquals(noncopyable.type     , 'noncopyable')
  AssertEquals(noncopyable.namespace, 'boost')
endfunction

"------------------------------------------------------------------------
function! s:Test_ptr_vector() " {{{2
  let ptr_vector = lh#cpp#types#get_info('ptr_vector')
  AssertEquals(ptr_vector.includes  , ['<boost/ptr_container.hpp>', '<boost/ptr_container/ptr_vector.hpp>'])
  AssertEquals(ptr_vector.name     , 'ptr_vector')
  AssertEquals(ptr_vector.type     , 'ptr_vector<%1>')
  AssertEquals(ptr_vector.namespace, 'boost')
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
