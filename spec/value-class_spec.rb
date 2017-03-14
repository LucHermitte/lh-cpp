# encoding: UTF-8
require 'spec_helper'
require 'pp'


RSpec.describe "C++ Value class wizard", :cpp, :class, :value do
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

  specify "value-class copyable", :cpp98, :cpp11, :copyable do
    expect(vim.command('MuTemplate cpp/value-class')).to eq ""
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Value object
     * - «Regular object»
     * - «Comparable»
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test»
    {
    public:

    };
    EOF
  end

  specify "value-class copyable, no implicit definition", :cpp11, :copyable, :defaulted do
    vim.command("let g:cpp_std_flavour = 11")
    vim.command("let g:cpp_explicit_default = 1")
    expect(vim.command('MuTemplate cpp/value-class')).to eq ""
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */

    /**
     * «Test».
     * @invariant «»
     * <p><b>Semantics</b><br>
     * - Value object
     * - «Regular object»
     * - «Comparable»
     * @author «author-name», creation
     * @since Version «1.0»
     */
    class «Test»
    {
    public:

        «Test»() = default;
        «Test»(«Test» const&) = default;
        «Test»& operator=(«Test» const&) = default;
        /**
         * Destructor.
         * @throw Nothing
         * @warning this class is not meant to be publicly inherited
         */
        ~«Test»() = default;
    };
    EOF
  end


end

# vim:set sw=2:
