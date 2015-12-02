# encoding: UTF-8
require 'spec_helper'
require 'pp'


RSpec.describe "C++ Value class w/ attributes wizard", :cpp, :class, :value, :with_attributes, :value_attributes do
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

  specify "value-attribute-class copyable", :cpp98, :cpp11, :copyable do
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/value-class")')).to match(/value-class.template/)
    expect(vim.command('call lh#mut#expand_and_jump(0, "cpp/internals/class-skeleton", {"attributes": [{"name": "foo", "type": "int"}, {"name": "bar", "type": "std::string", "includes":"<string>", "functions": ["set", "get"]}]})')).to match(/^$|#include <string> added/)
    vim.feedkeys('\<c-\>\<c-n>:silent! $call append("$", ["",""])\<cr>G')
    assert_buffer_contents <<-EOF
    #include <string>
    class «Test»
    {
    public:

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

  specify "value-attribute-class copyable, no implicit definition, C++11", :cpp11, :copyable, :defaulted do
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/value-class")')).to match(/value-class.template/)
    vim.command('let g:cpp_std_flavour=11')
    vim.command("let g:cpp_explicit_default = 1")
    expect(vim.command('call lh#mut#expand_and_jump(0, "cpp/internals/class-skeleton", {"attributes": [{"name": "foo", "type": "int"}, {"name": "bar", "type": "std::string", "includes":"<string>", "functions": ["set", "get"]}]})')).to match(/^$|#include <string> added/)
    vim.feedkeys('\<c-\>\<c-n>:silent! $call append("$", ["",""])\<cr>G')
    assert_buffer_contents <<-EOF
    #include <string>
    class «Test»
    {
    public:

        «Test»(«Test» const&) = default;
        «Test»& operator=(«Test» const&) = default;
        /**
         * Destructor.
         * @throw Nothing
         * @warning this class is not meant to be publicly inherited
         */
        ~«Test»() = default;
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

  #======================================================================
  # The same with pointer attributes that imply ... copy operations to be
  # explicited

  specify "value-attribute-class copyable, with ptr attributes", :cpp98, :cpp11, :copyable do
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/value-class")')).to match(/value-class.template/)
    expect(vim.command('call lh#mut#expand_and_jump(0, "cpp/internals/class-skeleton", {"use_copy_and_swap": 0, "attributes": [{"name": "foo", "type": "int"}, {"name": "bar", "type": "std::auto_ptr<std::string>", "includes":["<memory>", "<string>"], "functions": ["ref_set", "set", "get"]}]})')).to match(/^$|#include <string> added/)
    vim.feedkeys('\<c-\>\<c-n>:silent! $call append("$", ["",""])\<cr>G')
    # T* will require a destructor in current class
    # auto_ptr<> will require a destructor in current class, even empty
    # unique_ptr<>, doesn't require anything
    # Let's suppose other types to follow RAII
    #
    # Regarding getters:
    # - pointers are best avoided, IMO => references,
    # - or may be non_null<>.
    # - Only shared_ptr<> would deserved to be returned.  I don't know...
    # Regarding setters:
    # 1- one that takes a pointer that'll change the current one
    # 2- one that takes a value to assign in the pointer (if we're in a value
    # class, sommehow this means that the value behind the pointer could be
    # duplicated)
    assert_buffer_contents <<-EOF
    #include <memory>
    #include <string>
    class «Test»
    {
    public:

        /**
         * Copy constructor.
         * @param[in] rhs source data to be copied.
         * «@throw »
         */
        «Test»(«Test» const& rhs);
        /**
         * Assignment operator.
         * @param[in] rhs source data to be copied.
         * «@throw »
         */
        «Test»& operator=(«Test» const& rhs);
        /**
         * Destructor.
         * @throw Nothing
         * @warning this class is not meant to be publicly inherited
         */
        ~«Test»();
        «Test»(int foo, std::auto_ptr<std::string> bar)
            : m_foo(foo)
            , m_bar(bar)
            {}
        void setBar(std::string const& bar) {
            *m_bar = bar;
        }
        void setBar(std::auto_ptr<std::string> bar) {
            m_bar = bar;
        }
        std::string const& getBar() const {
            return *m_bar;
        }

    private:

        int                        m_foo;
        std::auto_ptr<std::string> m_bar;
    };
    EOF
  end

  specify "value-attribute-class copyable, no implicit definition, C++11", :cpp11, :copyable, :defaulted do
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/value-class")')).to match(/value-class.template/)
    vim.command('let g:cpp_std_flavour=11')
    vim.command("let g:cpp_explicit_default = 1")
    expect(vim.command('call lh#mut#expand_and_jump(0, "cpp/internals/class-skeleton", {"attributes": [{"name": "foo", "type": "int"}, {"name": "bar", "type": "std::string", "includes":"<string>", "functions": ["set", "get"]}]})')).to match(/^$|#include <string> added/)
    vim.feedkeys('\<c-\>\<c-n>:silent! $call append("$", ["",""])\<cr>G')
    assert_buffer_contents <<-EOF
    #include <string>
    class «Test»
    {
    public:

        «Test»(«Test» const&) = default;
        «Test»& operator=(«Test» const&) = default;
        /**
         * Destructor.
         * @throw Nothing
         * @warning this class is not meant to be publicly inherited
         */
        ~«Test»() = default;
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
