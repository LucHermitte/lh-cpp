# encoding: UTF-8
require 'spec_helper'
require 'pp'


# ======[ :Constructor {{{1
# Tests with parameters are done in *-class_spec.rb tests
# Test expanding with <Plug>MuT_ckword don't seem to work correctly
# TODO: C++11
RSpec.describe ":Constructor command", :cpp, :ctr_cmd do
  let (:filename) { "test.cpp" }

  # ====[ Always executed before each test {{{2
  before :each do
    vim.command('filetype plugin on')
    vim.command("file #{filename}")
    vim.set('ft=cpp')
    vim.set('expandtab')
    vim.set('sw=4')
    vim.command('silent! unlet g:cpp_explicit_default')
    vim.command('silent! unlet g:cpp_std_flavour')
    vim.command('silent! unlet g:mocked_input')
    vim.command('silent! unlet g:mocked_confirm')
    vim.command('silent! unlet g:cpp_use_copy_and_swap')
    if !defined? vim.runtime
        vim.define_singleton_method(:runtime) do |path|
            self.command("runtime #{path}")
        end
    end
    vim.runtime('spec/support/input-mock.vim')
    expect(vim.command('verbose function lh#ui#input')).to match(/input-mock.vim/)
    clear_buffer
    set_buffer_contents <<-EOF
      class Foo {
      public:

      private:
          std::string m_bar;
          int * m_foo;
      };
    EOF
    vim.write()
    vim.feedkeys('a\<esc>') # pause
    expect(system("ctags --c++-kinds=+p --fields=+imaS --extra=+q --language-force=C++ -f tags #{filename}")).to be true
    # system('less tags')
    vim.command("let b:tags_dirname = expand('%:p:h')")
    assert_buffer_contents <<-EOF
      class Foo {
      public:

      private:
          std::string m_bar;
          int * m_foo;
      };
    EOF
    expect(vim.echo('line("$")')).to eq '7'
    expect(vim.echo('setpos(".", [1,3,1,0])')).to eq '0'
    expect(vim.echo('line(".")')).to eq '3'
  end

  # ====[ default constructor {{{2
  context "when expanding default-constructor", :default_ctr do

    it "has a pointer attribute" do # {{{3
      # TODO: In C++11, no need for m_bar() if there is a default
      # initialisation at class scope
      # expect(vim.echo('lh#dev#class#attributes("Foo")')).to eq('m_bar')
      # expect(vim.echo('lh#cpp#constructors#debug("s:Attributes(\"Foo\")")')).to eq('m_bar')
      vim.command('Constructor default')
      # expect(vim.echo('g:step."--".string(g:implproto)')).to eq('42')
      # expect(vim.echo('g:step')).to eq('42')
      vim.feedkeys('a\<esc>') # pause
      assert_buffer_contents <<-EOF
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
    end

  end # }}}3

  # ====[ copy-constructor {{{2
  context "when expanding copy-constructor", :copy_ctr do
    it "has a pointer attribute" do # {{{3
      vim.command('Constructor copy')
      assert_buffer_contents <<-EOF
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
    end

  end # }}}3

  # ====[ assignment-operator {{{2
  context "when expanding assignment-operator", :assign_copy do

    it "has a pointer attribute" do # {{{3
      vim.command('let g:mocked_confirm = 0')
      vim.command('Constructor assign')
      assert_buffer_contents <<-EOF
        class Foo {
        public:
            /**
             * Assignment operator.
             * @param[in] rhs source data to be copied.
             * «@throw »
             */
            Foo& operator=(Foo const& rhs) ;
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
    end

  end # }}}3

  # ====[ copy'n'swap {{{2
  context "when expanding copy-and-swap", :copy_n_swap do

    it "has a pointer attribute" do # {{{3
      vim.command('let g:mocked_confirm = 1')
      vim.command('Constructor assign')
      assert_buffer_contents <<-EOF
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
            Foo& operator=(Foo rhs) {
                this->swap(rhs);
                return *this;
            }
            /**
             * Swap operation.
             * @param[in,out] other data with which content is swapped
             * @throw None
             */
            void swap(Foo & other) throw() ;
        private:
            std::string m_bar;
            int * m_foo;
        };

        void Foo::swap(Foo & other) throw ()
        {
            using std::swap;
            swap(m_bar, other.m_bar);
            swap(m_foo, other.m_foo);
        }
        EOF
    end

  end # }}}3

  # ====[ init constructor {{{2
  # No test for init-constructor as it requires a user-interaction and
  # vimrunner+vim client-server architecture doesn't work very-well together

# }}}2
end

# }}}1
# vim:set sw=2:fdm=marker:
