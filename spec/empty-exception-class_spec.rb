# encoding: UTF-8
require 'spec_helper'
require 'pp'


RSpec.describe "C++ empty-exception class wizard", :empty_exception, :cpp, :class do
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
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/empty-exception-class")')).to match(/empty-exception-class.template/)
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


  specify "empty_exception_class noncopyable, with implicit definitions, C++98", :cpp98 do
    expect(vim.command('MuTemplate cpp/empty-exception-class')).to match(/^$|#include <stdexcept> added/)
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <stdexcept>

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Exception class
     * - Copyable
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test» : public std::runtime_error
    {
    public:

        /**
         * Init constructor.
         * @param «ctr-parameters» «»
         * «@throw »
         */
        «Test»(«ctr-parameters»);
    };
    EOF
  end

  specify "empty_exception_class noncopyable, with implicit definitions, C++11", :cpp11 do
    vim.command('let g:cpp_std_flavour = 11')
    expect(vim.command('MuTemplate cpp/empty-exception-class')).to match(/^$|#include <stdexcept> added/)
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <stdexcept>

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Exception class
     * - Copyable
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test» : public std::runtime_error
    {
    public:

        using std::runtime_error::runtime_error;
    };
    EOF
  end

  specify "empty_exception_class noncopyable, no implicit definitions, C++11", :cpp11, :defaulted do
    vim.command('let g:cpp_std_flavour = 11')
    vim.command("let g:cpp_explicit_default = 1")
    expect(vim.command('MuTemplate cpp/empty-exception-class')).to match(/^$|#include <stdexcept> added/)
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <stdexcept>

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Exception class
     * - Copyable
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test» : public std::runtime_error
    {
    public:

        «Test»(«Test» const&) = default;
        «Test»& operator=(«Test» const&) = default;
        /**
         * Virtual destructor.
         * @throw Nothing
         */
        virtual ~«Test»() = default;
        using std::runtime_error::runtime_error;
    };
    EOF
  end

end

# vim:set sw=2:

