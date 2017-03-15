# encoding: UTF-8
require 'spec_helper'
require 'pp'


RSpec.describe "C++ class w/ attributes wizard", :cpp, :class, :with_attributes do
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
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/value-class")')).to match(/value-class.template/)
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

  specify "attribute-class copy-neutral, C++98", :cpp98 do
    expect(vim.command('call lh#mut#expand_and_jump(0, "cpp/internals/class-skeleton", {"attributes": [{"name": "foo", "type": "int"}, {"name": "str", "type": "string", "functions": ["set", "get"]}, {"name": "bar", "type": "Bar", "includes":"bar.h"}]})')).to match(/^$|#include <string> added/)
    vim.feedkeys('\<c-\>\<c-n>:silent! $call append("$", ["",""])\<cr>G')
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <string>
    #include "bar.h"

    /**
     * «Test».
     * @invariant «»
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test»
    {
    public:

        /**
         * Init constructor.
         * @param[in] foo «foo-explanations»
         * @param[in] str «str-explanations»
         * @param[in] bar «bar-explanations»
         * «@throw »
         */
        «Test»(int foo, std::string const& str, Bar const& bar)
            : m_foo(foo)
            , m_str(str)
            , m_bar(bar)
            {}
        void setStr(std::string const& str) {
            m_str = str;
        }
        std::string const& getStr() const {
            return m_str;
        }

    private:

        int         m_foo;
        std::string m_str;
        Bar         m_bar;
    };
    EOF
  end

  specify "attribute-class copy-neutral, C++11", :cpp11 do
    vim.command('silent! let g:cpp_std_flavour=11')
    expect(vim.command('call lh#mut#expand_and_jump(0, "cpp/internals/class-skeleton", {"attributes": [{"name": "foo", "type": "int"}, {"name": "bar", "type": "string", "functions": ["set", "get"]}]})')).to match(/^$|#include <string> added/)
    vim.feedkeys('\<c-\>\<c-n>:silent! $call append("$", ["",""])\<cr>G')
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <string>

    /**
     * «Test».
     * @invariant «»
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test»
    {
    public:

        /**
         * Init constructor.
         * @param[in] foo «foo-explanations»
         * @param[in] bar «bar-explanations»
         * «@throw »
         */
        «Test»(int foo, std::string const& bar)
            : m_foo(foo)
            , m_bar(bar)
            {}
        void setBar(std::string const& bar) {
            m_bar = bar;
        }
        std::string const& getBar() const {
            return m_bar;
        }

    private:

        int         m_foo;
        std::string m_bar;
    };
    EOF
  end


end

# vim:set sw=2:
