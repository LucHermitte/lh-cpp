# encoding: UTF-8
require 'spec_helper'
require 'pp'


RSpec.describe "C++ clonable class wizard", :clonable, :cpp, :class do
  let (:filename) { "test.cpp" }

  # ====[ Executed once before all test {{{2
  before :all do
    if !defined? vim.runtime
        vim.define_singleton_method(:runtime) do |path|
            self.command("runtime #{path}")
        end
    end
    vim.runtime('spec/support/input-mock.vim')
    expect(vim.command('verbose function lh#ui#input')).to match(/input-mock.vim/)
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/clonable-class")')).to match(/clonable-class.template/)
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
    clear_buffer
    set_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    EOF
    vim.command(%Q{call append(1, ['', ''])})
    expect(vim.echo('line("$")')).to eq '3'
    expect(vim.echo('setpos(".", [1,3,1,0])')).to eq '0'
    expect(vim.echo('line(".")')).to eq '3'
  end

  # ===============[ The base class ]=============

  specify "clonable_class noncopyable, with implicit definitions", :cpp98, :cpp11, :noncopyable do
    vim.command('silent! unlet g:cpp_noncopyable_class')
    expect(vim.command('MuTemplate cpp/clonable-class')).to match(/^$|#include <memory> added/)
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <memory>
    #include <boost/noncopyable.hpp>

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Clonable (but not assignable)
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test» : private boost::noncopyable
    {
    public:

        /**
         * Virtual destructor.
         * @throw Nothing
         */
        virtual ~«Test»();
        virtual std::auto_ptr<«Test»> clone() const {
            return std::auto_ptr<«Test»>(new «Test»(*this));
        }

    protected:

        /**
         * Default constructor.
         * «@throw »
         */
        «Test»();
        «Test»(«Test» const&) /* = default */;
    };
    EOF
  end

  specify "clonable_class noncopyable, no implicit definitions, C++11", :cpp11, :noncopyable, :defaulted do
    vim.command('silent! unlet g:cpp_noncopyable_class')
    vim.command("let g:cpp_std_flavour = 11")
    vim.command("let g:cpp_explicit_default = 1")
    expect(vim.command('MuTemplate cpp/clonable-class')).to match(/^$|#include <memory> added/)
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <memory>
    #include <boost/noncopyable.hpp>

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Clonable (but not assignable)
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test» : private boost::noncopyable
    {
    public:

        /**
         * Virtual destructor.
         * @throw Nothing
         */
        virtual ~«Test»();
        virtual std::unique_ptr<«Test»> clone() const {
            return std::unique_ptr<«Test»>(new «Test»(*this));
        }

    protected:

        «Test»() = default;
        «Test»(«Test» const&) = default;

    private:

        «Test»& operator=(«Test» const&) = delete;
    };
    EOF
  end

  specify "clonable_class noncopyable, no implicit definitions, C++14", :cpp14, :noncopyable, :defaulted do
    vim.command('silent! unlet g:cpp_noncopyable_class')
    vim.command("let g:cpp_std_flavour = 14")
    vim.command("let g:cpp_explicit_default = 1")
    expect(vim.command('MuTemplate cpp/clonable-class')).to match(/^$|#include <memory> added/)
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <memory>
    #include <boost/noncopyable.hpp>

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Clonable (but not assignable)
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test» : private boost::noncopyable
    {
    public:

        /**
         * Virtual destructor.
         * @throw Nothing
         */
        virtual ~«Test»();
        virtual std::unique_ptr<«Test»> clone() const {
            return std::make_unique(*this);
        }

    protected:

        «Test»() = default;
        «Test»(«Test» const&) = default;

    private:

        «Test»& operator=(«Test» const&) = delete;
    };
    EOF
  end

  specify "clonable_class C++98 alone", :cpp98, :deleted do
    vim.command('let g:cpp_noncopyable_class=""')
    vim.command('let g:cpp_std_flavour = 03')
    expect(vim.command('MuTemplate cpp/clonable-class')).to match(/^$|#include <memory> added/)
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <memory>

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Clonable (but not assignable)
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test»
    {
    public:

        /**
         * Virtual destructor.
         * @throw Nothing
         */
        virtual ~«Test»();
        virtual std::auto_ptr<«Test»> clone() const {
            return std::auto_ptr<«Test»>(new «Test»(*this));
        }

    protected:

        /**
         * Default constructor.
         * «@throw »
         */
        «Test»();
        «Test»(«Test» const&) /* = default */;

    private:

        «Test»& operator=(«Test» const&) /* = delete */;
    };
    EOF
  end

  specify "clonable_class C++11 alone, w/ implicit definition", :cpp11, :deleted do
    vim.command('let g:cpp_noncopyable_class = ""')
    vim.command('let g:cpp_std_flavour = 11')
    expect(vim.command('MuTemplate cpp/clonable-class')).to match(/^$|#include <memory> added/)
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <memory>

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Clonable (but not assignable)
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test»
    {
    public:

        /**
         * Virtual destructor.
         * @throw Nothing
         */
        virtual ~«Test»();
        virtual std::unique_ptr<«Test»> clone() const {
            return std::unique_ptr<«Test»>(new «Test»(*this));
        }

    protected:

        /**
         * Default constructor.
         * «@throw »
         */
        «Test»();
        «Test»(«Test» const&) = default;

    private:

        «Test»& operator=(«Test» const&) = delete;
    };
    EOF
  end

  specify "clonable_class C++11 alone, no implicit definition", :cpp11, :deleted, :defaulted do
    vim.command('let g:cpp_noncopyable_class = ""')
    vim.command('let g:cpp_std_flavour = 11')
    vim.command("let g:cpp_explicit_default = 1")
    expect(vim.command('MuTemplate cpp/clonable-class')).to match(/^$|#include <memory> added/)
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <memory>

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Clonable (but not assignable)
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test»
    {
    public:

        /**
         * Virtual destructor.
         * @throw Nothing
         */
        virtual ~«Test»();
        virtual std::unique_ptr<«Test»> clone() const {
            return std::unique_ptr<«Test»>(new «Test»(*this));
        }

    protected:

        «Test»() = default;
        «Test»(«Test» const&) = default;

    private:

        «Test»& operator=(«Test» const&) = delete;
    };
    EOF
  end

  # ===============[ base class + cloable child ]=============

  specify "clonable_class base noncopyable, with implicit definitions + child", :cpp98, :cpp11, :noncopyable, :clonable_child do
    vim.command('silent! unlet g:cpp_noncopyable_class')
    # expect(vim.command('MuTemplate cpp/clonable-class')).to match(/^$|#include <memory> added/)
    expect(vim.command('call lh#mut#expand_and_jump(0, "cpp/clonable-class", {"clsname": "base"})')).to match(/^$|#include <memory> added/)
    # vim.feedkeys('\<esc>G')
    # vim.type('<c-\><c-n>$:put=""<cr>$:put=""<cr>G')
    vim.feedkeys('\<c-\>\<c-n>:silent! $call append("$", ["",""])\<cr>G')
    vim.write()
    # pp vim.echo('expand("%:p")')
    # pp system('pwd')
    expect(system("ctags --c++-kinds=+p --fields=+imaS --extra=+q --language-force=C++ -f tags #{filename}")).to be true
    vim.command("let b:tags_dirname = expand('%:p:h')")

    expect(vim.command('call lh#mut#expand_and_jump(0, "cpp/clonable-class", {"clsname": "child", "parents": [{"base": {}}]})')).to match(/^$|memory is already included/)
    # pp vim.echo('g:root_clones')

    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <memory>
    #include <boost/noncopyable.hpp>

    /**
     * base.
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Clonable (but not assignable)
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class base : private boost::noncopyable
    {
    public:

        /**
         * Virtual destructor.
         * @throw Nothing
         */
        virtual ~base();
        virtual std::auto_ptr<base> clone() const {
            return std::auto_ptr<base>(new base(*this));
        }

    protected:

        /**
         * Default constructor.
         * «@throw »
         */
        base();
        base(base const&) /* = default */;
    };

    /**
     * child.
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Clonable (but not assignable)
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class child : public base
    {
    public:

        /**
         * Virtual destructor.
         * @throw Nothing
         */
        virtual ~child();
        /**
         * Init constructor.
         * @param «ctr-parameters» «»
         * «@throw »
         */
        child(«ctr-parameters»);
        virtual std::auto_ptr<base> clone() const /* override */ {
            return std::auto_ptr<base>(new child(*this));
        }

    protected:

        child(child const&) /* = default */;
    };
    EOF
  end
end

# vim:set sw=2:
