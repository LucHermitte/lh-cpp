"=============================================================================
" File:         tests/lh/constructor-command.vim                  {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.1.
let s:k_version = '221'
" Created:      09th Mar 2021
" Last Update:  10th Mar 2021
"------------------------------------------------------------------------
" Description:
"       Test :Constructor command
" }}}1
"=============================================================================

UTSuite [lh-cpp] Testing :Constructor

let s:cpo_save=&cpo
set cpo&vim

runtime autoload/lh/cpp/constructors.vim
runtime plugin/common_brackets.vim " :Brackets, used in ftplugin/c/c_snippets.vim
runtime plugin/misc_map.vim        " :Inoreab, used in ftplugin/c/c_snippets.vim
runtime plugin/mu-template.vim
runtime plugin/lh-style.vim        " :UseStyle
runtime spec/support/input-mock.vim

call lh#cpp#GotoFunctionImpl#verbose(1)
call lh#cpp#AnalysisLib_Function#verbose(1)

function! s:BeforeAll() abort
  call lh#window#create_window_with('sp test-constructor.cpp')
  call lh#style#clear()
  " call lh#cpp#GotoFunctionImpl#force_api('vimscript')
  let tpl_dirs = filter(copy(lh#mut#dirs#update()), "isdirectory(v:val)")
  AssertMatches!(join(tpl_dirs, ','), 'lh-cpp')
  UseStyle breakbeforebraces=stroustrup -ft=c
  UseStyle spacesbeforeparens=control-statements -ft=c
  UseStyle empty_braces=empty -ft=c

  let b:tags_dirname = expand('%:p:h')
  let &l:tags .= ','.b:tags_dirname.'/tags'
  setlocal expandtab
  setlocal sw=4
endfunction

function! s:AfterAll() abort
  silent bw! test-constructor.cpp
endfunction

function! s:Setup() abort
  call lh#let#unlet('g:cpp_explicit_default')
  call lh#let#unlet('g:cpp_std_flavour')
  call lh#let#unlet('g:mocked_input')
  call lh#let#unlet('g:mocked_confirm')
  call lh#let#unlet('g:cpp_use_copy_and_swap')

  SetBufferContent trim << EOF
  class Foo {
  public:

  private:
      std::string m_bar;
      int * m_foo;
  };
  EOF

  AssertEquals(line('$'), 7)
  call setpos('.', [1, 3, 1, 0])
  AssertEquals(line('.'), 3)
  let attributes = lh#dev#class#attributes('Foo', 1)
  let attrb_names = sort(lh#list#get(attributes, 'name'))
  AssertEquals(attrb_names, ['Foo::m_bar', 'Foo::m_foo'])
endfunction


"------------------------------------------------------------------------
function! s:Test_default_ctr() abort
  let g:cpp_std_flavour = 03
  AssertEquals(&ft, 'cpp')
  call lh#cpp#constructors#Main("default")
  AssertBufferMatch trim << EOF
  class Foo {
  public:
      /**
       * Default constructor.
       * «@throw »
       */
      Foo();
  private:
      std::string m_bar;
      int * m_foo;
  };

  Foo::Foo()
  : m_bar()
  , m_foo()
  {}
  EOF
endfunction

"------------------------------------------------------------------------
function! s:Test_copy_ctr() abort
  let g:cpp_std_flavour = 03
  AssertEquals(&ft, 'cpp')
  AssertEquals(line('.'), 3)
  " Try a pause...
  exe "normal! a\<esc>"
  call lh#cpp#constructors#Main("copy")
  " Constructor copy
  AssertBufferMatch trim << EOF
  class Foo {
  public:
      /**
       * Copy constructor.
       * @param[in] rhs source data to be copied.
       * «@throw »
       */
      Foo(Foo const& rhs);
  private:
      std::string m_bar;
      int * m_foo;
  };

  Foo::Foo(Foo const& rhs)
  : m_bar(rhs.m_bar)
  , m_foo(«duplicate(rhs.m_foo)»)
  {}
  EOF
endfunction

"------------------------------------------------------------------------
function! s:Test_assign_operator() abort
  let g:cpp_std_flavour = 03
  let g:mocked_confirm = 0
  AssertEquals(&ft, 'cpp')
  AssertEquals(line('.'), 3)
  call lh#cpp#constructors#Main("assign")
  AssertBufferMatch trim << EOF
  class Foo {
  public:
      /**
       * Assignment operator.
       * @param[in] rhs source data to be copied.
       * «@throw »
       */
      Foo& operator=(Foo const& rhs);
  private:
      std::string m_bar;
      int * m_foo;
  };

  Foo& Foo::operator=(Foo const& rhs)
  {
      m_bar = rhs.m_bar;
      m_foo = «duplicate(rhs.m_foo)»;
  }

  EOF
endfunction

"------------------------------------------------------------------------
function! s:Test_copy_n_swap() abort
  let g:cpp_std_flavour = 03
  let g:mocked_confirm = 1
  AssertEquals(&ft, 'cpp')
  AssertEquals(line('.'), 3)
  call lh#cpp#constructors#Main("assign")
  AssertBufferMatch trim << EOF
  class Foo {
  public:
      /**
       * Assignment operator.
       * @param[in] rhs source data to be copied.
       * «@throw »
       *
       * @note based on copy-and-swap idiom, with copy-elision exploited
       * @note exception-safe
       */
      Foo& operator=(Foo rhs)
      {
          this->swap(rhs);
          return *this;
      }
      /**
       * Swap operation.
       * @param[in,out] other data with which content is swapped
       * @throw None
       */
      void swap(Foo & other) throw();
  private:
      std::string m_bar;
      int * m_foo;
  };

  void Foo::swap(Foo & other) throw()
  {
      using std::swap;
      swap(m_bar, other.m_bar);
      swap(m_foo, other.m_foo);
  }

  EOF
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
