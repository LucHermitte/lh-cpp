"=============================================================================
" File:		syntax/cpp-cxxtest.vim                            {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.0.
" Created:	23rd Apr 2009
" Last Update:	16th Dec 2015
"------------------------------------------------------------------------
" Description:	C++ syntax enhancements for CxxTest <http://cxxtest.sf.net/>
" assertions.
"
"------------------------------------------------------------------------
" Option:
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------

syn keyword cppCxxTest TS_FAIL
syn keyword cppCxxTest TS_ASSERT
syn keyword cppCxxTest TS_ASSERT_EQUALS
syn keyword cppCxxTest TS_ASSERT_SAME_DELTA
syn keyword cppCxxTest TS_ASSERT_DIFFERS
syn keyword cppCxxTest TS_ASSERT_LESS_THAN
syn keyword cppCxxTest TS_ASSERT_LESS_THAN_EQUALS
syn keyword cppCxxTest TS_ASSERT_PREDICATE
syn keyword cppCxxTest TS_ASSERT_RELATION
syn keyword cppCxxTest TS_ASSERT_THROWS
syn keyword cppCxxTest TS_ASSERT_THROWS_EQUALS
syn keyword cppCxxTest TS_ASSERT_THROWS_ASSERT
syn keyword cppCxxTest TS_ASSERT_THROWS_ANYTHING
syn keyword cppCxxTest TS_ASSERT_THROWS_NOTHING
syn keyword cppCxxTest TS_WARN
syn keyword cppCxxTest TS_TRACE

syn keyword cppCxxTest TSM_FAIL
syn keyword cppCxxTest TSM_ASSERT
syn keyword cppCxxTest TSM_ASSERT_EQUALS
syn keyword cppCxxTest TSM_ASSERT_SAME_DELTA
syn keyword cppCxxTest TSM_ASSERT_DIFFERS
syn keyword cppCxxTest TSM_ASSERT_LESS_THAN
syn keyword cppCxxTest TSM_ASSERT_LESS_THAN_EQUALS
syn keyword cppCxxTest TSM_ASSERT_PREDICATE
syn keyword cppCxxTest TSM_ASSERT_RELATION
syn keyword cppCxxTest TSM_ASSERT_THROWS
syn keyword cppCxxTest TSM_ASSERT_THROWS_EQUALS
syn keyword cppCxxTest TSM_ASSERT_THROWS_ASSERT
syn keyword cppCxxTest TSM_ASSERT_THROWS_ANYTHING
syn keyword cppCxxTest TSM_ASSERT_THROWS_NOTHING
syn keyword cppCxxTest TSM_WARN
syn keyword cppCxxTest TSM_TRACE

hi def link cppCxxTest Special

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
