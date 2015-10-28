"=============================================================================
" File:         tests/lh/analysis.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      2.0.0.b15
let s:k_version = '2.0.0b15'
" Created:      17th Feb 2015
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Unit Tests for AnalysisLic
" }}}1
"=============================================================================

UTSuite [lh-cpp] Testing lh/cpp/AnalysisLib_Class

runtime autoload/lh/cpp/AnalysisLib_Class.vim

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
function! s:Test_simplify_id()
  " Partial Match up to last ns
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['',   'a', 'a::b']    ) == 'C'
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['::', 'a::', 'a::b::']) == 'C'
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['a',   'a::b']        ) == 'C'
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['a::', 'a::b::']      ) == 'C'

  " Partial Match (of first ns)
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['a', 'a::z']          ) == 'b::C'
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['a::', 'a::z::']      ) == 'b::C'

  " No Match
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['z', 'a::z']          ) == 'a::b::C'
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['z::', 'a::z::']      ) == 'a::b::C'
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['',   'z', 'a::z']    ) == 'a::b::C'
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['::', 'z::', 'a::z::']) == 'a::b::C'

  " Full Match
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['a', 'a::b::C']          ) == ''
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['a::', 'a::b::C::']      ) == ''
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['',   'b', 'a::b::C']    ) == ''
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['::', 'b::', 'a::b::C::']) == ''
endfunction

function! s:Test_simplify_id_and_show_ns()
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['',   'a', 'a::b']    , 1) == ['a::b::', 'C']
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['::', 'a::', 'a::b::'], 1) == ['a::b::', 'C']
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['a',   'a::b']        , 1) == ['a::b::', 'C']
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['a::', 'a::b::']      , 1) == ['a::b::', 'C']

  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['a', 'a::z']          , 1) == ['a::', 'b::C']
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['a::', 'a::z::']      , 1) == ['a::', 'b::C']

  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['z', 'a::z']          , 1) == ['', 'a::b::C']
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['z::', 'a::z::']      , 1) == ['', 'a::b::C']
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['',   'z', 'a::z']    , 1) == ['', 'a::b::C']
  Assert lh#cpp#AnalysisLib_Class#simplify_id('a::b::C', ['::', 'z::', 'a::z::'], 1) == ['', 'a::b::C']
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
