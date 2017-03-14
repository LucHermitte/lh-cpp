# encoding: UTF-8
require 'spec_helper'
require 'pp'


RSpec.describe "C++ non virtual base class wizard", :base_nv, :cpp, :class do
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
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/base-class-non-virtual")')).to match(/base-class-non-virtual.template/)
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

  specify "base-class-non-virtual noncopyable, with implicit definitions", :cpp98, :cpp11, :noncopyable do
    vim.command('silent! unlet g:cpp_noncopyable_class')
    expect(vim.command('MuTemplate cpp/base-class-non-virtual')).to match(/^$|#include <boost\/noncopyable.hpp> added/)
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <boost/noncopyable.hpp>

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Entity
     * - Non-copyable
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test» : private boost::noncopyable
    {
    public:


    protected:

        /**
         * Default constructor.
         * «@throw »
         */
        «Test»();
        /**
         * Destructor.
         * @throw Nothing
         * @note This class is not meant to be destroyed polymorphically
         */
        ~«Test»();
    };
    EOF
  end

  specify "base-class-non-virtual noncopyable, no implicit definitions", :cpp11, :noncopyable, :defaulted do
    vim.command('silent! unlet g:cpp_noncopyable_class')
    vim.command("let g:cpp_std_flavour = 11")
    vim.command("let g:cpp_explicit_default = 1")
    expect(vim.command('MuTemplate cpp/base-class-non-virtual')).to match(/^$|#include <boost\/noncopyable.hpp> added/)
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <boost/noncopyable.hpp>

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Entity
     * - Non-copyable
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test» : private boost::noncopyable
    {
    public:


    protected:

        «Test»() = default;
        /**
         * Destructor.
         * @throw Nothing
         * @note This class is not meant to be destroyed polymorphically
         */
        ~«Test»() = default;

    private:

        «Test»(«Test» const&) = delete;
        «Test»& operator=(«Test» const&) = delete;
    };
    EOF
  end

  specify "base-class-non-virtual C++98 alone", :cpp98, :deleted do
    vim.command('let g:cpp_noncopyable_class=""')
    vim.command('let g:cpp_std_flavour = 03')
    expect(vim.command('MuTemplate cpp/base-class-non-virtual')).to eq ""
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Entity
     * - Non-copyable
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test»
    {
    public:


    protected:

        /**
         * Default constructor.
         * «@throw »
         */
        «Test»();
        /**
         * Destructor.
         * @throw Nothing
         * @note This class is not meant to be destroyed polymorphically
         */
        ~«Test»();

    private:

        «Test»(«Test» const&) /* = delete */;
        «Test»& operator=(«Test» const&) /* = delete */;
    };
    EOF
  end

  specify "base-class-non-virtual C++11 alone, w/ implicit definition", :cpp11, :deleted do
    vim.command('let g:cpp_noncopyable_class = ""')
    vim.command('let g:cpp_std_flavour = 11')
    expect(vim.command('MuTemplate cpp/base-class-non-virtual')).to eq ""
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Entity
     * - Non-copyable
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test»
    {
    public:


    protected:

        /**
         * Default constructor.
         * «@throw »
         */
        «Test»();
        /**
         * Destructor.
         * @throw Nothing
         * @note This class is not meant to be destroyed polymorphically
         */
        ~«Test»();

    private:

        «Test»(«Test» const&) = delete;
        «Test»& operator=(«Test» const&) = delete;
    };
    EOF
  end

  specify "base-class-non-virtual C++11 alone, no implicit definition", :cpp11, :deleted, :defaulted do
    vim.command('let g:cpp_noncopyable_class = ""')
    vim.command('let g:cpp_std_flavour = 11')
    vim.command("let g:cpp_explicit_default = 1")
    expect(vim.command('MuTemplate cpp/base-class-non-virtual')).to eq ""
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Entity
     * - Non-copyable
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test»
    {
    public:


    protected:

        «Test»() = default;
        /**
         * Destructor.
         * @throw Nothing
         * @note This class is not meant to be destroyed polymorphically
         */
        ~«Test»() = default;

    private:

        «Test»(«Test» const&) = delete;
        «Test»& operator=(«Test» const&) = delete;
    };
    EOF
  end


end

# vim:set sw=2:
