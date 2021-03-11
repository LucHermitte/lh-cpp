"=============================================================================
" File:         tests/lh/stream-operator.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.1.
let s:k_version = '221'
" Created:      10th Mar 2021
" Last Update:  11th Mar 2021
"------------------------------------------------------------------------
" Description:
"               Test snippets for operator<< and operator>>
"------------------------------------------------------------------------
" Note:
" - Requires mu-template 4.4.0
"=============================================================================

UTSuite [lh-cpp] Testing snippets for << and >>

" ## Dependencies {{{1
let s:cpo_save=&cpo
set cpo&vim

runtime plugin/common_brackets.vim " :Brackets, used in ftplugin/c/c_snippets.vim
runtime plugin/misc_map.vim        " :Inoreab, used in ftplugin/c/c_snippets.vim
runtime plugin/mu-template.vim
runtime plugin/lh-style.vim        " :UseStyle
runtime spec/support/input-mock.vim

"=============================================================================
" ## Fixtures {{{1
function! s:BeforeAll() abort " {{{2
  call lh#window#create_window_with('sp test-stream-operator.cpp')
  call lh#style#clear()
  " call lh#cpp#GotoFunctionImpl#force_api('vimscript')
  let tpl_dirs = filter(copy(lh#mut#dirs#update()), "isdirectory(v:val)")
  AssertMatches!(join(lh#mut#dirs#get_templates_for("cpp/stream-inserter"), ','), 'stream-inserter.template')
  AssertMatches!(join(lh#mut#dirs#get_templates_for("cpp/stream-extractor"), ','), 'stream-extractor.template')
  SetMarker <+ +>
  " UseStyle breakbeforebraces=stroustrup -ft=c
  UseStyle indent_brace_style=java -ft=c
  UseStyle spacesbeforeparens=control-statements -ft=c
  UseStyle empty_braces=empty -ft=c

  let b:tags_dirname = expand('%:p:h')
  let &l:tags .= ','.b:tags_dirname.'/tags'
  setlocal expandtab
  setlocal sw=4
  " Comment "runtimepath is ".&rtp
endfunction

function! s:AfterAll() abort
  silent bw! test-stream-operator.cpp
  runtime autoload/lh/ui.vim
endfunction

function! s:Setup() abort " {{{2
  " TODO: use lh#on#exit
  call lh#let#unlet('g:cpp_explicit_default')
  call lh#let#unlet('g:cpp_std_flavour')
  call lh#let#unlet('g:mocked_input')
  call lh#let#unlet('g:mocked_confirm')
  call lh#let#unlet('g:cpp_place_const_after_type')
endfunction

"=============================================================================
" ## Tests {{{1
" # Subscenario fixtures {{{2
function! s:prepare_any_fields_buffer() abort " subscenario fixture {{{3
  SetBufferContent trim << EOF
  class Foo {
  public:

  private:
      int * m_foo_bar;
      std::string m_barFoo;
  };
  EOF

  AssertEquals(line('$'), 7)
  call setpos('.', [0, 3, 1, 0])
  AssertEquals(line('.'), 3)
  let attributes = lh#dev#class#attributes('Foo', 1)
  let attrb_names = lh#list#get(attributes, 'name')
  " Comment string(attributes)
  AssertEquals(attrb_names, ['Foo::m_foo_bar', 'Foo::m_barFoo'])
endfunction

" # Operator<< {{{2

" Function: s:Test_inserter_any_fields_empty_east_const() {{{3
function! s:Test_inserter_any_fields_empty_east_const() abort
  " east-const is lh-dev default
  call s:prepare_any_fields_buffer()
  let g:mocked_confirm = 1
  MuTemplate cpp/stream-inserter
  AssertBufferMatch trim << EOF
  #include <ostream>
  class Foo {
  public:
      friend std::ostream & operator<<(std::ostream & os, Foo const& v) {
          return os << <+fields+>;
      }
      <++>
  private:
      int * m_foo_bar;
      std::string m_barFoo;
  };
  EOF
endfunction

" Function: s:Test_inserter_any_fields_empty_const_west() {{{3
function! s:Test_inserter_any_fields_empty_const_west() abort
  call s:prepare_any_fields_buffer()

  let g:cpp_place_const_after_type = 0
  let g:mocked_confirm = 1

  MuTemplate cpp/stream-inserter
  AssertBufferMatch trim << EOF
  #include <ostream>
  class Foo {
  public:
      friend std::ostream & operator<<(std::ostream & os, const Foo& v) {
          return os << <+fields+>;
      }
      <++>
  private:
      int * m_foo_bar;
      std::string m_barFoo;
  };
  EOF
endfunction

" Function: s:Test_inserter_any_fields_with_space_east_const() {{{3
function! s:Test_inserter_any_fields_with_space_east_const() abort
  " east-const is lh-dev default
  call s:prepare_any_fields_buffer()
  let g:mocked_confirm = 2
  MuTemplate cpp/stream-inserter
  AssertBufferMatch trim << EOF
  #include <ostream>
  class Foo {
  public:
      friend std::ostream & operator<<(std::ostream & os, Foo const& v) {
          return os << v.m_foo_bar << ' ' << v.m_barFoo;
      }
      <++>
  private:
      int * m_foo_bar;
      std::string m_barFoo;
  };
  EOF
endfunction

" Function: s:Test_inserter_any_fields_with_names_east_const() {{{3
function! s:Test_inserter_any_fields_with_names_east_const() abort
  " east-const is lh-dev default
  call s:prepare_any_fields_buffer()
  let g:mocked_confirm = 3
  MuTemplate cpp/stream-inserter
  AssertBufferMatch trim << EOF
  #include <ostream>
  class Foo {
  public:
      friend std::ostream & operator<<(std::ostream & os, Foo const& v) {
          return os
              << "foo bar: " << v.m_foo_bar
              << "bar foo: " << v.m_barFoo;
      }
      <++>
  private:
      int * m_foo_bar;
      std::string m_barFoo;
  };
  EOF
endfunction

"------------------------------------------------------------------------
" Function: s:Test_inserter_any_fields_as_array_east_const() {{{3
function! s:Test_inserter_any_fields_as_array_east_const() abort
  " east-const is lh-dev default
  call s:prepare_any_fields_buffer()
  let g:mocked_confirm = 4
  MuTemplate cpp/stream-inserter
  AssertBufferMatch trim << EOF
  #include <ostream>
  class Foo {
  public:
      friend std::ostream & operator<<(std::ostream & os, Foo const& v) {
          return os << '{' << v.m_foo_bar << ", " << v.m_barFoo << '}';
      }
      <++>
  private:
      int * m_foo_bar;
      std::string m_barFoo;
  };
  EOF
endfunction

" # Operator>> {{{2

" Function: s:Test_extractor_any_fields_empty_east_const() {{{3
function! s:Test_extractor_any_fields_empty_east_const() abort
  " east-const is lh-dev default
  call s:prepare_any_fields_buffer()
  let g:mocked_confirm = 1
  MuTemplate cpp/stream-extractor
  AssertBufferMatch trim << EOF
  #include <istream>
  class Foo {
  public:
      friend std::istream & operator>>(std::istream & is, Foo& v) {
          return is >> <+fields+>;
      }
      <++>
  private:
      int * m_foo_bar;
      std::string m_barFoo;
  };
  EOF
endfunction

" Function: s:Test_extractor_any_fields_empty_const_west() {{{3
function! s:Test_extractor_any_fields_empty_const_west() abort
  call s:prepare_any_fields_buffer()

  let g:cpp_place_const_after_type = 0
  let g:mocked_confirm = 1

  MuTemplate cpp/stream-extractor
  AssertBufferMatch trim << EOF
  #include <istream>
  class Foo {
  public:
      friend std::istream & operator>>(std::istream & is, Foo& v) {
          return is >> <+fields+>;
      }
      <++>
  private:
      int * m_foo_bar;
      std::string m_barFoo;
  };
  EOF
endfunction

" Function: s:Test_extractor_any_fields_with_spaces_east_const() {{{3
function! s:Test_extractor_any_fields_with_spaces_east_const() abort
  " east-const is lh-dev default
  call s:prepare_any_fields_buffer()
  let g:mocked_confirm = 2
  MuTemplate cpp/stream-extractor
  AssertBufferMatch trim << EOF
  #include <istream>
  class Foo {
  public:
      friend std::istream & operator>>(std::istream & is, Foo& v) {
          return is >> v.m_foo_bar >> v.m_barFoo;
      }
      <++>
  private:
      int * m_foo_bar;
      std::string m_barFoo;
  };
  EOF
endfunction

"------------------------------------------------------------------------

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
