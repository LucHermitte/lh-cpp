"=============================================================================
" File:         tests/lh/snippets.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.0.
let s:k_version = '220'
" Created:      25th Nov 2015
" Last Update:  15th Dec 2015
"------------------------------------------------------------------------
" Description:
"       Test autoload/lh/snippets.vim functions
" }}}1
"=============================================================================

UTSuite [lh-cpp] Testing lh/cpp/snippets.vim

runtime autoload/lh/cpp/on.vim
runtime autoload/lh/cpp/snippets.vim

let s:cpo_save=&cpo
set cpo&vim

" ## Tests {{{1
"------------------------------------------------------------------------
function! s:Test_noexcept() " {{{2
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
function! s:Test_deleted() " {{{2
  let cleanup = lh#on#exit()
        \.restore_option('cpp_deleted')
        \.restore_option('cpp_std_flavour')
        \.restore('$CXXFLAGS')
  silent! unlet g:cpp_std_flavour
  silent! unlet b:cpp_std_flavour
  silent! unlet g:cpp_deleted
  silent! unlet b:cpp_deleted
  let $CXXFLAGS = ''
  try
    AssertEquals(lh#cpp#snippets#deleted(), '/* = delete */')

    let b:cpp_std_flavour = 11
    AssertEquals(lh#cpp#snippets#deleted(), '= delete')

    let g:cpp_deleted = 'ITK_DELETE'
    AssertEquals(lh#cpp#snippets#deleted(), 'ITK_DELETE')

    unlet b:cpp_std_flavour
    AssertEquals(lh#cpp#snippets#deleted(), 'ITK_DELETE')
  finally
    call cleanup.finalize()
  endtry
endfunction

"------------------------------------------------------------------------
function! s:Test_defaulted() " {{{2
  let cleanup = lh#on#exit()
        \.restore_option('cpp_defaulted')
        \.restore_option('cpp_std_flavour')
        \.restore('$CXXFLAGS')
  silent! unlet g:cpp_std_flavour
  silent! unlet b:cpp_std_flavour
  silent! unlet g:cpp_defaulted
  silent! unlet b:cpp_defaulted
  let $CXXFLAGS = ''
  try
    AssertEquals(lh#cpp#snippets#defaulted(), '/* = default */')

    let b:cpp_std_flavour = 11
    AssertEquals(lh#cpp#snippets#defaulted(), '= default')

    let g:cpp_defaulted = 'ITK_DEFAULT'
    AssertEquals(lh#cpp#snippets#defaulted(), 'ITK_DEFAULT')

    unlet b:cpp_std_flavour
    AssertEquals(lh#cpp#snippets#defaulted(), 'ITK_DEFAULT')
  finally
    call cleanup.finalize()
  endtry
endfunction

"------------------------------------------------------------------------
" Function: s:Test_parents() {{{2
function! s:Test_parents() abort
  let parents = []
  AssertEquals(lh#cpp#snippets#parents(parents), ['', []])

  let parents += [ {"boost::noncopyable" : {"how": "include", "visibility": "private"}}]
  AssertEquals(lh#cpp#snippets#parents(parents), [" : private boost::noncopyable", []])

  let parents += [ {"SomeBase" : {}}]
  AssertEquals(lh#cpp#snippets#parents(parents), ["\n: private boost::noncopyable\n, public SomeBase", []])

  let parents += [ {"Base2" : {"virtual": 1}}]
  AssertEquals(lh#cpp#snippets#parents(parents), ["\n: private boost::noncopyable\n, public SomeBase\n, public virtual Base2", []])

  " Start from new, uses lh#cpp#types
  let parents = [ {"noncopyable" : {"how": "include", "visibility": "private"}}]
  AssertEquals(lh#cpp#snippets#parents(parents), [" : private boost::noncopyable", ['<boost/noncopyable.hpp>']])

endfunction


" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
