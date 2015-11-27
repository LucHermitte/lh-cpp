# encoding: UTF-8
require 'spec_helper'
require 'pp'


RSpec.describe "C++ exception class wizard", :exception, :cpp, :class do
  let (:filename) { "test.cpp" }

  before :each do
    vim.command('filetype plugin on')
    vim.command("file #{filename}")
    vim.set('ft=cpp')
    vim.set('expandtab')
    vim.set('sw=4')
    vim.command('silent! unlet g:cpp_explicit_default')
    vim.command('silent! unlet g:cpp_std_flavour')
    vim.command('silent! unlet g:cpp_root_exception')
    clear_buffer
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/exception-class")')).to match(/exception-class.template/)
  end


  specify "exception_class, with implicit definitions, C++98", :cpp98 do
    expect(vim.command('MuTemplate cpp/exception-class')).to match(/^$|#include <stdexcept> added/)
    assert_buffer_contents <<-EOF
    #include <stdexcept>
    class «Test» : public std::runtime_error
    {
    public:

        «Test»(«ctr-parameters»);
        virtual char const* what() const throw() /* override */;
    };
    EOF
  end

  specify "exception_class, with implicit definitions, C++11", :cpp11 do
    vim.command('let g:cpp_std_flavour = 11')
    expect(vim.command('MuTemplate cpp/exception-class')).to match(/^$|#include <stdexcept> added/)
    assert_buffer_contents <<-EOF
    #include <stdexcept>
    class «Test» : public std::runtime_error
    {
    public:

        using std::runtime_error::runtime_error;
        virtual char const* what() const noexcept override;
    };
    EOF
  end

  specify "exception_class, no implicit definitions, C++11", :cpp11, :defaulted do
    vim.command('let g:cpp_std_flavour = 11')
    vim.command("let g:cpp_explicit_default = 1")
    expect(vim.command('MuTemplate cpp/exception-class')).to match(/^$|#include <stdexcept> added/)
    assert_buffer_contents <<-EOF
    #include <stdexcept>
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
        virtual char const* what() const noexcept override;
    };
    EOF
  end

  # ----------------------------------------------------------------------
  specify "domain (param) exception_class, with implicit definitions, C++98", :cpp98 do
    expect(vim.command('call lh#mut#expand_and_jump(0, "cpp/exception-class", {"root-exception": {"std::logic_error": {"includes": "<stdexcept>"}}})')).to match(/^$|#include <stdexcept> added/)
    assert_buffer_contents <<-EOF
    #include <stdexcept>
    class «Test» : public std::logic_error
    {
    public:

        «Test»(«ctr-parameters»);
        virtual char const* what() const throw() /* override */;
    };
    EOF
  end

  specify "domain (option) exception_class, with implicit definitions, C++98", :cpp98 do
    vim.command('let g:cpp_root_exception = {"std::logic_error": {"includes": "<stdexcept>"}}')
    expect(vim.command('MuTemplate cpp/exception-class')).to match(/^$|#include <stdexcept> added/)
    assert_buffer_contents <<-EOF
    #include <stdexcept>
    class «Test» : public std::logic_error
    {
    public:

        «Test»(«ctr-parameters»);
        virtual char const* what() const throw() /* override */;
    };
    EOF
  end


end

# vim:set sw=2:
