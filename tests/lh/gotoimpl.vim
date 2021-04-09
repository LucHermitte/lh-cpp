"=============================================================================
" File:         tests/lh/gotoimpl.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.1.
let s:k_version = '221'
" Created:      02nd Apr 2021
" Last Update:  09th Apr 2021
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
"   - variadic template
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

" Function: s:Test_empty_single_arg() {{{2
function! s:Test_empty_int_function() abort
  SetBufferContent trim << EOF
  int myfunc2(int i);
  EOF
  :1
  GOTOIMPL
  AssertBufferMatches! trim << EOF
  int myfunc2(int i);

  int myfunc2(int i)
  {}
  EOF

  " Test search
  :1
  GOTOIMPL
  AssertEq(line('.'), 3)
endfunction

" Function: s:Test_function_with_default_values() {{{2
function! s:Test_function_with_default_values() abort
  SetBufferContent trim << EOF
  #include <string>
  int myfunc(
      std::string const              s2,
      std::string      &             s3,
      std::string     && /* h=heh */ s4,
      std::string const&             s1 = "",
      int                            i1 = 5,
      double                         d  = 4.);
  EOF
  :2
  GOTOIMPL
  AssertBufferMatches! trim << EOF
  #include <string>
  int myfunc(
      std::string const              s2,
      std::string      &             s3,
      std::string     && /* h=heh */ s4,
      std::string const&             s1 = "",
      int                            i1 = 5,
      double                         d  = 4.);

  int myfunc(
      std::string const              s2,
      std::string      &             s3,
      std::string     && /* h=heh */ s4,
      std::string const&             s1 /* = "" */,
      int                            i1 /* = 5 */,
      double                         d /* = 4. */)
  {}
  EOF

  " Test search
  :2
  GOTOIMPL
  AssertEq(line('.'), 10)
endfunction

"------------------------------------------------------------------------
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
" Function: s:Test_noexcept_function() {{{2
function! s:Test_noexcept_function() abort
  SetBufferContent trim << EOF
  #include <string>
  int myfunc(
      std::string const& s1,
      std::string const  s2,
      std::string      & s3,
      std::string     && s4,
      int                i1,
      double             d) noexcept;
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
      double             d) noexcept;

  int myfunc(
      std::string const& s1,
      std::string const  s2,
      std::string      & s3,
      std::string     && s4,
      int                i1,
      double             d) noexcept
  {}
  EOF

  " Test search
  :2
  GOTOIMPL
  AssertEq(line('.'), 10)
endfunction

"------------------------------------------------------------------------
" Function: s:Test_tpl_function() {{{2
function! s:Test_tpl_function() abort
  SetBufferContent trim << EOF
  template <int I, typename T>
  int myfunc2(T v);
  EOF
  :2
  GOTOIMPL
  AssertBufferMatches! trim << EOF
  template <int I, typename T>
  int myfunc2(T v);

  template <int I, typename T>
  int myfunc2(T v)
  {}
  EOF

  " Test search
  :2
  GOTOIMPL
  AssertEq(line('.'), 5)
endfunction

" Function: s:Test_tpl_function_with_template_bool_type() {{{2
function! s:Test_tpl_function_with_template_bool_type() abort
  SetBufferContent trim << EOF
  template <bool> struct sometype{ int i;};
  template <int I>
  int myfunc2(sometype<I==42> i);
  EOF
  :3
  GOTOIMPL
  AssertBufferMatches! trim << EOF
  template <bool> struct sometype{ int i;};
  template <int I>
  int myfunc2(sometype<I==42> i);

  template <int I>
  int myfunc2(sometype<I==42> i)
  {}
  EOF

  " Test search
  :3
  GOTOIMPL
  AssertEq(line('.'), 6)
endfunction

" Function: s:Test_tpl_function_with_template_bool_type_and_def_value() {{{2
function! s:Test_tpl_function_with_template_bool_type_and_def_value() abort
  SetBufferContent trim << EOF
  template <bool> struct sometype{ int i;};
  template <int I>
  int myfunc2(sometype<I==42> i = 12);
  EOF
  :3
  GOTOIMPL
  AssertBufferMatches! trim << EOF
  template <bool> struct sometype{ int i;};
  template <int I>
  int myfunc2(sometype<I==42> i = 12);

  template <int I>
  int myfunc2(sometype<I==42> i /* = 12 */)
  {}
  EOF

  " Test search
  :3
  GOTOIMPL
  AssertEq(line('.'), 6)
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
