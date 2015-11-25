# encoding: UTF-8
require 'spec_helper'
require 'pp'


RSpec.describe "C++ non virtual base class wizard", :cpp, :class, :abstract do
  let (:filename) { "test.cpp" }

  before :each do
    vim.command('filetype plugin on')
    vim.command("file #{filename}")
    vim.set('ft=cpp')
    vim.set('expandtab')
    vim.set('sw=4')
    clear_buffer
  end

  it "has loaded C++ ftplugin", :deps => true do
    # pp vim.echo('&rtp')
    # pp vim.command(':scriptnames')
    expect(/plugin.mu-template\.vim/).to be_sourced
    # expect(/ftplugin.cpp.cpp_snippets\.vim/).to be_sourced
    vim.command('call lh#mut#dirs#update()')
    expect(vim.echo('g:lh#mut#dirs#cache')).to match(/cpp/)
    # pp vim.echo('g:lh#mut#dirs#cache')

    expect(vim.echo('lh#dev#naming#type("toto")')).to eq "Toto"
  end

  specify "base-class-non-virtual noncopyable", :cpp98, :cpp11, :noncopyable do
    vim.command('silent! unlet g:cpp_noncopyable_class')
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/base-class-non-virtual")')).to match(/base-class-non-virtual.template/)
    expect(vim.command('MuTemplate cpp/base-class-non-virtual')).to eq ""
    assert_buffer_contents <<-EOF
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

  specify "base-class-non-virtual C++98 alone", :cpp98, :deleted do
    vim.command('let g:cpp_noncopyable_class=""')
    vim.command('let g:cpp_std_flavour = 03')
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/base-class-non-virtual")')).to match(/base-class-non-virtual.template/)
    expect(vim.command('MuTemplate cpp/base-class-non-virtual')).to eq ""
    assert_buffer_contents <<-EOF
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

  specify "base-class-non-virtual C++11 alone", :cpp11, :deleted do
    vim.command('let g:cpp_noncopyable_class = ""')
    vim.command('let g:cpp_std_flavour = 11')
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/base-class-non-virtual")')).to match(/base-class-non-virtual.template/)
    expect(vim.command('MuTemplate cpp/base-class-non-virtual')).to eq ""
    assert_buffer_contents <<-EOF
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


end

# vim:set sw=2:


