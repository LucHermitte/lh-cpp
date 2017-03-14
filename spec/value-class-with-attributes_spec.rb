# encoding: UTF-8
require 'spec_helper'
require 'pp'


# ======[ Value class w/ attributes {{{1
RSpec.describe "C++ Value class w/ attributes wizard", :cpp, :class, :value, :with_attributes, :value_attributes do
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
    set_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    EOF
    vim.command(%Q{call append(1, ['', ''])})
    expect(vim.echo('line("$")')).to eq '3'
    expect(vim.echo('setpos(".", [1,3,1,0])')).to eq '0'
    expect(vim.echo('line(".")')).to eq '3'
  end

  # ====[ implictly copyable, explicit definitions, C++98 {{{2
  specify "value-attribute-class copyable", :cpp98, :cpp11, :copyable do
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/value-class")')).to match(/value-class.template/)
    expect(vim.command('call lh#mut#expand_and_jump(0, "cpp/value-class", {"attributes": [{"name": "foo", "type": "int"}, {"name": "bar", "type": "string", "functions": ["set", "get"]}]})')).to match(/^$|#include <string> added/)
    vim.feedkeys('\<c-\>\<c-n>:silent! $call append("$", ["",""])\<cr>G')
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <string>

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

  # ====[ implictly copyable, NO explicit definitions, C++11 {{{2
  specify "value-attribute-class copyable, no explicit definition, C++11", :cpp11, :copyable, :defaulted do
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/value-class")')).to match(/value-class.template/)
    vim.command('let g:cpp_std_flavour=11')
    vim.command("let g:cpp_explicit_default = 1")
    expect(vim.command('call lh#mut#expand_and_jump(0, "cpp/value-class", {"attributes": [{"name": "foo", "type": "int"}, {"name": "bar", "type": "string", "functions": ["set", "get"]}]})')).to match(/^$|#include <string> added/)
    vim.feedkeys('\<c-\>\<c-n>:silent! $call append("$", ["",""])\<cr>G')
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <string>

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

        «Test»(«Test» const&) = default;
        «Test»& operator=(«Test» const&) = default;
        /**
         * Destructor.
         * @throw Nothing
         * @warning this class is not meant to be publicly inherited
         */
        ~«Test»() = default;
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

  # ====[ explicit copy, implicit definitions, no-swap, C++98 {{{2
  #======================================================================
  # The same with pointer attributes that imply ... copy operations to be
  # explicited

  specify "value-attribute-class copyable, with ptr attributes", :cpp98, :cpp11, :copyable do
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/value-class")')).to match(/value-class.template/)
    expect(vim.command('call lh#mut#expand_and_jump(0, "cpp/value-class", {"use_copy_and_swap": 0, "attributes": [{"name": "foo", "type": "int"}, {"name": "bar", "type": "std::auto_ptr<std::string>", "includes":["<memory>", "<string>"], "functions": ["ref_set", "set", "get"]}]})')).to match(/^$|#include <string> added/)
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
    # class, somehow this means that the value behind the pointer could be
    # duplicated)
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <memory>
    #include <string>

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

        /**
         * Copy constructor.
         * @param[in] rhs source data to be copied.
         * «@throw »
         */
        «Test»(«Test» const& rhs)
            : m_foo(rhs.m_foo)
            , m_bar(«duplicate(rhs.m_bar)»)
            {}
        /**
         * Assignment operator.
         * @param[in] rhs source data to be copied.
         * «@throw »
         */
        «Test»& operator=(«Test» const& rhs) {
            m_foo = rhs.m_foo;
            m_bar = «duplicate(rhs.m_bar)»;
        }
        /**
         * Destructor.
         * @throw Nothing
         * @warning this class is not meant to be publicly inherited
         */
        ~«Test»();
        /**
         * Init constructor.
         * @param[in] foo «foo-explanations»
         * @param«[in]» bar «bar-explanations»
         * «@throw »
         * @pre `bar != NULL`«»
         */
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

  # ====[ explicit copy, implicit definitions, copy-n-swap, C++98 {{{2
  specify "value-attribute-class copyable, with ptr attributes", :cpp98, :cpp11, :copyable, :copy_n_swap do
    expect(vim.echo('lh#mut#dirs#get_templates_for("cpp/value-class")')).to match(/value-class.template/)
    expect(vim.command('call lh#mut#expand_and_jump(0, "cpp/value-class", {"use_copy_and_swap": 1, "attributes": [{"name": "foo", "type": "int"}, {"name": "bar", "type": "std::auto_ptr<std::string>", "includes":["<memory>", "<string>"], "functions": ["ref_set", "set", "get"]}]})')).to match(/^$|#include <string> added/)
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
    # class, somehow this means that the value behind the pointer could be
    # duplicated)
    assert_buffer_contents <<-EOF
    /** File Header line to trick auto-inclusion */
    #include <memory>
    #include <string>

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

        /**
         * Copy constructor.
         * @param[in] rhs source data to be copied.
         * «@throw »
         */
        «Test»(«Test» const& rhs)
            : m_foo(rhs.m_foo)
            , m_bar(«duplicate(rhs.m_bar)»)
            {}
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
        void swap(«Test» & other) throw() {
            using std::swap;
            swap(m_foo, other.m_foo);
            swap(m_bar, other.m_bar);
        }
        /**
         * Destructor.
         * @throw Nothing
         * @warning this class is not meant to be publicly inherited
         */
        ~«Test»();
        /**
         * Init constructor.
         * @param[in] foo «foo-explanations»
         * @param«[in]» bar «bar-explanations»
         * «@throw »
         * @pre `bar != NULL`«»
         */
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

# }}}2
end

# }}}1
# vim:set sw=2:
