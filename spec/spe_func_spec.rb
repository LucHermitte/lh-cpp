# encoding: UTF-8
require 'spec_helper'
require 'pp'


# ======[ Special functions {{{1
# Tests with parameters are done in *-class_spec.rb tests
# Test expanding with <Plug>MuT_ckword don't seem to work correctly
# TODO: C++11
RSpec.describe "Special functions", :cpp, :spe_func do
  let (:filename) { "test.cpp" }
  
  before :all do
    if !defined? vim.runtime
        vim.define_singleton_method(:runtime) do |path|
            self.command("runtime #{path}")
        end
    end
    vim.runtime('spec/support/input-mock.vim')
    expect(vim.command('verbose function lh#ui#input')).to match(/input-mock.vim/)
  end

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
    clear_buffer
  end

  # ====[ default constructor {{{2
  context "when expanding default-constructor", :default_ctr do
    it "asks the user, when the only context is the filename" do
      expect(vim.command('MuTemplate cpp/default-constructor')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Default constructor.
         * «@throw »
         */
        «Test»();
        EOF
    end

    it "takes the class name as a parameter" do
      expect(vim.command('MuTemplate cpp/default-constructor FooBar')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Default constructor.
         * «@throw »
         */
        FooBar();
        EOF
    end

    it "recognizes it's within a class definition" do
      set_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      assert_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      expect(vim.echo('line("$")')).to eq '3'
      expect(vim.echo('setpos(".", [1,2,1,0])')).to eq '0'
      expect(vim.echo('line(".")')).to eq '2'
      expect(vim.command('MuTemplate cpp/default-constructor')).to match(/^$/)
      assert_buffer_contents <<-EOF
      class Foo {
          /**
           * Default constructor.
           * «@throw »
           */
          Foo();
      };
      EOF
    end
  end

  # ====[ copy-constructor {{{2
  context "when expanding copy-constructor", :copy_ctr do
    it "asks the user, when the only context is the filename" do
      expect(vim.command('MuTemplate cpp/copy-constructor')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Copy constructor.
         * @param[in] rhs source data to be copied.
         * «@throw »
         */
        «Test»(«Test» const& rhs);
        EOF
    end

    it "takes the class name as a parameter" do
      expect(vim.command('MuTemplate cpp/copy-constructor FooBar')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Copy constructor.
         * @param[in] rhs source data to be copied.
         * «@throw »
         */
        FooBar(FooBar const& rhs);
        EOF
    end

    it "recognizes it's within a class definition" do
      set_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      assert_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      expect(vim.echo('line("$")')).to eq '3'
      expect(vim.echo('setpos(".", [1,2,1,0])')).to eq '0'
      expect(vim.echo('line(".")')).to eq '2'
      expect(vim.command('MuTemplate cpp/copy-constructor')).to match(/^$/)
      assert_buffer_contents <<-EOF
      class Foo {
          /**
           * Copy constructor.
           * @param[in] rhs source data to be copied.
           * «@throw »
           */
          Foo(Foo const& rhs);
      };
      EOF
    end
  end

  # ====[ assignment-operator {{{2
  context "when expanding assignment-operator", :assign_copy do

    it "asks the user, when the only context is the filename (copy'n'swap choice made by user)" do
      vim.command('let g:mocked_confirm = 0')
      expect(vim.command('MuTemplate cpp/assignment-operator')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Assignment operator.
         * @param[in] rhs source data to be copied.
         * «@throw »
         */
        «Test»& operator=(«Test» const& rhs);
        EOF
    end

    it "asks the user, when the only context is the filename" do
      vim.command('let g:cpp_use_copy_and_swap = 0')
      expect(vim.command('MuTemplate cpp/assignment-operator')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Assignment operator.
         * @param[in] rhs source data to be copied.
         * «@throw »
         */
        «Test»& operator=(«Test» const& rhs);
        EOF
    end

    it "takes the class name as a parameter (copy'n'swap choice made by user)" do
      vim.command('let g:mocked_confirm = 0')
      expect(vim.command('MuTemplate cpp/assignment-operator FooBar')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Assignment operator.
         * @param[in] rhs source data to be copied.
         * «@throw »
         */
        FooBar& operator=(FooBar const& rhs);
        EOF
    end

    it "recognizes it's within a class definition (copy'n'swap choice made by user)" do
      vim.command('let g:mocked_confirm = 0')
      set_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      assert_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      expect(vim.echo('line("$")')).to eq '3'
      expect(vim.echo('setpos(".", [1,2,1,0])')).to eq '0'
      expect(vim.echo('line(".")')).to eq '2'
      expect(vim.command('MuTemplate cpp/assignment-operator')).to match(/^$/)
      assert_buffer_contents <<-EOF
      class Foo {
          /**
           * Assignment operator.
           * @param[in] rhs source data to be copied.
           * «@throw »
           */
          Foo& operator=(Foo const& rhs);
      };
      EOF
    end
  end

  # ====[ copy'n'swap {{{2
  context "when expanding copy-and-swap", :copy_n_swap do

    it "asks the user, when the only context is the filename (copy'n'swap choice made by user)" do
      vim.command('let g:mocked_confirm = 1')
      expect(vim.command('MuTemplate cpp/assignment-operator')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Assignment operator.
         * @param[in] rhs source data to be copied.
         * «@throw »
         *
         * @note based on copy-and-swap idiom, with copy-elision exploited
         * @note exception-safe
         */
        «Test»& operator=(«Test» rhs) {
            this->swap(rhs);
            return *this;
        }
        /**
         * Swap operation.
         * @param[in,out] other data with which content is swapped
         * @throw None
         */
        void swap(«Test» & other) throw();
        EOF
    end

    it "asks the user, when the only context is the filename" do
      vim.command('let g:cpp_use_copy_and_swap = 1')
      expect(vim.command('MuTemplate cpp/assignment-operator')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Assignment operator.
         * @param[in] rhs source data to be copied.
         * «@throw »
         *
         * @note based on copy-and-swap idiom, with copy-elision exploited
         * @note exception-safe
         */
        «Test»& operator=(«Test» rhs) {
            this->swap(rhs);
            return *this;
        }
        /**
         * Swap operation.
         * @param[in,out] other data with which content is swapped
         * @throw None
         */
        void swap(«Test» & other) throw();
        EOF
    end

    it "takes the class name as a parameter (copy'n'swap choice made by user)" do
      vim.command('let g:mocked_confirm = 1')
      expect(vim.command('MuTemplate cpp/assignment-operator FooBar')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Assignment operator.
         * @param[in] rhs source data to be copied.
         * «@throw »
         *
         * @note based on copy-and-swap idiom, with copy-elision exploited
         * @note exception-safe
         */
        FooBar& operator=(FooBar rhs) {
            this->swap(rhs);
            return *this;
        }
        /**
         * Swap operation.
         * @param[in,out] other data with which content is swapped
         * @throw None
         */
        void swap(FooBar & other) throw();
        EOF
    end

    it "recognizes it's within a class definition (copy'n'swap choice made by user)" do
      vim.command('let g:mocked_confirm = 1')
      set_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      assert_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      expect(vim.echo('line("$")')).to eq '3'
      expect(vim.echo('setpos(".", [1,2,1,0])')).to eq '0'
      expect(vim.echo('line(".")')).to eq '2'
      expect(vim.command('MuTemplate cpp/assignment-operator')).to match(/^$/)
      assert_buffer_contents <<-EOF
      class Foo {
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
          void swap(Foo & other) throw();
      };
      EOF
    end
  end

  # ====[ destructor {{{2
  context "when expanding destructor", :destructor do
    it "asks the user, when the only context is the filename" do
      expect(vim.command('MuTemplate cpp/destructor')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * «virtual »destructor.
         * @throw Nothing
         */
        «virtual »~«Test»();
        EOF
    end

    it "takes the class name as a parameter" do
      expect(vim.command('MuTemplate cpp/destructor FooBar')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * «virtual »destructor.
         * @throw Nothing
         */
        «virtual »~FooBar();
        EOF
    end

    it "recognizes it's within a class definition" do
      set_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      assert_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      expect(vim.echo('line("$")')).to eq '3'
      expect(vim.echo('setpos(".", [1,2,1,0])')).to eq '0'
      expect(vim.echo('line(".")')).to eq '2'
      expect(vim.command('MuTemplate cpp/destructor')).to match(/^$/)
      assert_buffer_contents <<-EOF
      class Foo {
          /**
           * «virtual »destructor.
           * @throw Nothing
           */
          «virtual »~Foo();
      };
      EOF
    end
  end

  # ====[ init constructor {{{2
  context "when expanding init-constructor", :init_ctr do
    it "asks the user, when the only context is the filename" do
      expect(vim.command('MuTemplate cpp/init-constructor')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Init constructor.
         * @param «ctr-parameters» «»
         * «@throw »
         */
        «Test»(«ctr-parameters»);
        EOF
    end

    it "takes the class name as a parameter" do
      expect(vim.command('MuTemplate cpp/init-constructor FooBar')).to match(/^$/)
        assert_buffer_contents <<-EOF
        /**
         * Init constructor.
         * @param «ctr-parameters» «»
         * «@throw »
         */
        FooBar(«ctr-parameters»);
        EOF
    end

    it "recognizes it's within a class definition" do
      set_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      assert_buffer_contents <<-EOF
      class Foo {

      };
      EOF
      expect(vim.echo('line("$")')).to eq '3'
      expect(vim.echo('setpos(".", [1,2,1,0])')).to eq '0'
      expect(vim.echo('line(".")')).to eq '2'
      expect(vim.command('MuTemplate cpp/init-constructor')).to match(/^$/)
      assert_buffer_contents <<-EOF
      class Foo {
          /**
           * Init constructor.
           * @param «ctr-parameters» «»
           * «@throw »
           */
          Foo(«ctr-parameters»);
      };
      EOF
    end
  end

# }}}2
end

# }}}1
# vim:set sw=2:fdm=marker:
