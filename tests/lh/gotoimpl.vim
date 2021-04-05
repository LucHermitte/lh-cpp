"=============================================================================
" File:         tests/lh/gotoimpl.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.1.
let s:k_version = '221'
" Created:      02nd Apr 2021
" Last Update:  05th Apr 2021
"------------------------------------------------------------------------
" Description:
"       Test :GOTOIMPL and :MOVEIMPL
" }}}1
"=============================================================================

UTSuite [lh-cpp] Testing :GOTOIMPL

runtime autoload/lh/cpp/GotoFunctionImpl.vim
runtime plugin/common_brackets.vim " :Brackets, used in ftplugin/c/c_snippets.vim
runtime plugin/misc_map.vim        " :Inoreab, used in ftplugin/c/c_snippets.vim
runtime plugin/mu-template.vim
runtime plugin/lh-style.vim        " :UseStyle
runtime spec/support/input-mock.vim

let s:cpo_save=&cpo
set cpo&vim

" call lh#cpp#GotoFunctionImpl#verbose(1)
" call lh#cpp#AnalysisLib_Function#verbose(1)

" ## Fixtures {{{1
function! s:BeforeAll() abort
  let cleanup = lh#on#exit()
        \.restore('g:mt_IDontWantTemplatesAutomaticallyInserted')
        \.restore('&undolevels')
  try
    let g:mt_IDontWantTemplatesAutomaticallyInserted = 1
    call lh#window#create_window_with('sp test-gotoimpl.cpp')
  finally
    call cleanup.finalize()
  endtry
  call lh#style#clear()
  " call lh#cpp#GotoFunctionImpl#force_api('vimscript')
  UseStyle breakbeforebraces=stroustrup -b
  UseStyle spacesbeforeparens=control-statements -b
  UseStyle empty_braces=empty -b

  let b:tags_dirname = expand('%:p:h')
  let &l:tags .= ','.b:tags_dirname.'/tags'
  setlocal expandtab
  setlocal sw=2
  " Comment "runtimepath is ".&rtp
endfunction

function! s:AfterAll() abort
  silent bw! test-gotoimpl.cpp
  runtime autoload/lh/ui.vim
endfunction

function! s:Setup() abort
  call lh#let#unlet('g:cpp_explicit_default')
  call lh#let#unlet('g:cpp_std_flavour')
  call lh#let#unlet('g:mocked_input')
  call lh#let#unlet('g:mocked_confirm')
  " It seems that SetBufferContent merges changes with previous levels,
  " but we need force updating TranslationUnit
  set undolevels&vim
endfunction

" ## Tests {{{1
" - procedure
" - function
" - w/ parameters
" - operators
" - constructors
"   - default: w/|w/o explicit
" - destructor
" - w/|w/o
"   - virtual
"   - noexcept
"   - override
"   - final
"
" * if libclang
" - template function
" - template class
" - template func in template class
"
" * duplicate situations
" - X class
" - X namespace
" - w/ | w/o comments
" - w/ | w/o param names
" - w/ libclang or vimscript
"
" * Errors
" - = default, = delete, = 0
"
"------------------------------------------------------------------------
" Function: s:Test_empty_procedure() {{{2
function! s:Test_empty_procedure() abort
  SetBufferContent trim << EOF
  void myfunc();
  EOF
  :1
  GOTOIMPL
  AssertBufferMatches! trim << EOF
  void myfunc();

  void myfunc()
  {}
  EOF

  " Test search
  :1
  GOTOIMPL
  AssertEq(line('.'), 3)
endfunction

" Function: s:Test_empty_int_function() {{{2
function! s:Test_empty_int_function() abort
  SetBufferContent trim << EOF
  int myfunc2();
  EOF
  :1
  GOTOIMPL
  AssertBufferMatches! trim << EOF
  int myfunc2();

  int myfunc2()
  {}
  EOF

  " Test search
  :1
  GOTOIMPL
  AssertEq(line('.'), 3)
endfunction

" Function: s:Test_function() {{{2
function! s:Test_function() abort
  SetBufferContent trim << EOF
  #include <string>
  int myfunc(
      std::string const& s1,
      std::string const  s2,
      std::string      & s3,
      std::string     && s4,
      int                i1,
      double             d);
  EOF
  :2
  GOTOIMPL
  AssertBufferMatches! trim << EOF
  #include <string>
  int myfunc(
      std::string const& s1,
      std::string const  s2,
      std::string      & s3,
      std::string     && s4,
      int                i1,
      double             d);

  int myfunc(
      std::string const& s1,
      std::string const  s2,
      std::string      & s3,
      std::string     && s4,
      int                i1,
      double             d)
  {}
  EOF

  " Test search
  :2
  GOTOIMPL
  AssertEq(line('.'), 10)
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
