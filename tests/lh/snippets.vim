"=============================================================================
" File:         tests/lh/snippets.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.1.7.
let s:k_version = '217'
" Created:      25th Nov 2015
" Last Update:
"------------------------------------------------------------------------
" Description:
"       Test autoload/lh/snippets.vim functions
" }}}1
"=============================================================================

UTSuite [lh-cpp] Testing lh/cpp/snippets.vim

runtime autoload/lh/cpp/snippets.vim

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
function! s:Test_noexcept()
  let cleanup = lh#on#exit()
        \.restore_option('cpp_noexcept')
        \.restore_option('cpp_std_flavour')
        \.restore('$CXXFLAGS')
  silent! unlet g:cpp_std_flavour
  silent! unlet b:cpp_std_flavour
  silent! unlet g:cpp_noexcept
  silent! unlet b:cpp_noexcept
  let $CXXFLAGS = ''
  try
    AssertEquals(lh#cpp#snippets#noexcept(), 'throw()')
    AssertEquals(lh#cpp#snippets#noexcept('false'), 'throw()')

    let b:cpp_std_flavour = 11
    AssertEquals(lh#cpp#snippets#noexcept(), 'noexcept')
    AssertEquals(lh#cpp#snippets#noexcept('false'), 'noexcept(false)')

    let g:cpp_noexcept = 'ITK_NOEXCEPT%1'
    AssertEquals(lh#cpp#snippets#noexcept(), 'ITK_NOEXCEPT')
    AssertEquals(lh#cpp#snippets#noexcept('false'), 'ITK_NOEXCEPT(false)')

    unlet b:cpp_std_flavour
    AssertEquals(lh#cpp#snippets#noexcept(), 'ITK_NOEXCEPT')
    AssertEquals(lh#cpp#snippets#noexcept('false'), 'ITK_NOEXCEPT(false)')
  finally
    call cleanup.finalize()
  endtry
endfunction

"------------------------------------------------------------------------
" Function: s:Test_parents() {{{3
function! s:Test_parents() abort
  let parents = []
  AssertEquals(lh#cpp#snippets#parents(parents), "")

  let parents += [ {"boost::noncopyable" : {"how": "include", "visibility": "private"}}]
  AssertEquals(lh#cpp#snippets#parents(parents), ": private boost::noncopyable")

  let parents += [ {"SomeBase" : {}}]
  AssertEquals(lh#cpp#snippets#parents(parents), "\n: private boost::noncopyable\n, public SomeBase")

  let parents += [ {"Base2" : {"virtual": 1}}]
  AssertEquals(lh#cpp#snippets#parents(parents), "\n: private boost::noncopyable\n, public SomeBase\n, public virtual Base2")

endfunction


"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
