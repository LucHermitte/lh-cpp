# encoding: UTF-8
require 'spec_helper'
require 'pp'


RSpec.describe "C++ Value class wizard", :cpp, :class, :value do
  let (:filename) { "test.cpp" }

  before :each do
    vim.command('filetype plugin on')
    vim.command("file #{filename}")
    vim.set('ft=cpp')
    vim.set('expandtab')
    vim.set('sw=4')
    vim.command('silent! unlet g:cpp_explicit_default')
    vim.command('silent! unlet g:cpp_std_flavour')
    clear_buffer
  end

    specify "value-class copyable", :cpp98, :cpp11, :copyable do
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/value-class")')).to match(/value-class.template/)
    expect(vim.command('MuTemplate cpp/value-class')).to eq ""
    assert_buffer_contents <<-EOF
    class «Test»
    {
    public:

    };
    EOF
  end

  specify "value-class copyable, no implicit definition", :cpp11, :copyable, :defaulted do
    vim.command("let g:cpp_std_flavour = 11")
    vim.command("let g:cpp_explicit_default = 1")
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/value-class")')).to match(/value-class.template/)
    expect(vim.command('MuTemplate cpp/value-class')).to eq ""
    assert_buffer_contents <<-EOF
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


