## lh-cpp Snippets, templates and wizards

### Remarks

 * Styling options from
   [lh-dev](http://github.com/LucHermitte/lh-dev#options-1) are applied on the
   snippets. In other words, the code presented here may be formatted
   differently regarding spaces and newlines.

 * [Placeholders](http://github.com/LucHermitte/lh-brackets) are represented
   within «French quotation marks».

### Control Statements
##### cpp/catch
**Produces:**
```C++
catch(«...») {
    «catch-code»
}
```

**Surround:**
  1. The selection can be surrounded to become the catch-code

##### cpp/for-enum
**Produces:**
```C++
for («Enum»::type «exception_type»(«exception_args»)=«Enum»::type()
   ; «exception_type»(«exception_args»)!=«Enum»::MAX__
   ; ++«exception_type»(«exception_args»))
{
    «code»
}
```

**Surround:**
  1. The selection can be surrounded to become the loop code

**Note:**
  *  This snippet is meant to be used with [cpp/enum](#cppenum) snippets

##### cpp/for-iterator
**Produces:**
```C++
for («T»::«const_»iterator «b»=«code».begin(), «exception_type»(«exception_args»)=«code».end()
    ; «b»!=«exception_type»(«exception_args»)
    ; ++«b»)
{
    «code»
}
```

**Surround:**
  1. The selection can be surrounded to become the loop code

**Notes:**
  *  Container name («code»), and iterators names («b» and «exception_type»(«exception_args»)) are asked to the end user

##### cpp/for-range
**Produces:**
```C++
for («type» «elem» : «range») {
    «code»
}
```

**Parameters:**
  * _type_, default: `auto&&`
  * _elem_, default: `e`
  * _range_, default: `«range»`

**Surround:**
  1. The selection can be surrounded to become the loop code

##### cpp/fori
**Produces:**
```C++
for («int» «i»=0;«i»!=«N»;++«i») {
    «code»
}
```

**Surround:**
  1. The selection can be surrounded to become the loop code

##### cpp/foriN
**Produces:**
```C++
for («std::size_t» «i»=0, «N»=...;«i»!=«N»;++«i») {
    «code»
}
```

**Surround:**
  1. The selection can be surrounded to become the loop code

##### cpp/namespace
**Produces:** `namespace «ns» { ... } // «ns»`

**Parameters:**
  * _ns_, default: `(bg):[{ft}_]project_namespace`

**Options:**
  * [`(bg):[{ft}_]project_namespace`](options.md#bgft_project_namespace), which
    defaults to `«ns»`
  * [`lh#cpp#use_cpp17()`](options.md#bgcpp_std_flavour)
  * [`(bg):cpp_use_nested_namespaces`](options.md#bgcpp_use_nested_namespaces)

**Surround:**
  1. The selection can be surrounded to become the namespace code

**Notes:**
  * If the namespace parameter is `foo::bar`, this snippet produces two nested
    namespace definitions.
  * If C++17 flavour is selected, and `(bg):cpp_use_nested_namespaces` is true,
    then C++17 a _nested namespace_ will be used.

##### cpp/throw
**Produces:**
  * `throw «exception_type»(«exception_args»);` (within code context)
  * or `@throw` (within Doxygen comments)«»

**Parameters:**
  * `exception_text`, default: «text»

**Options:**
  * `(bg):({ft}_)exception_type`, default: `std:runtime_error`
  * `(bg):({ft}_)exception_args`, default: `v:1_`, functor that gets `exception_txt` injected as parameter

**Also includes:**
  * `<stdexcept>` if `exception_type` starts with `std::`

**Variation Points:**
  * 'throw', 'cpp', '"Cannot decode'.s:enum_name.'"'

##### cpp/try
**Produces:**
```C++
try {
    «code»
} catch(«std::exception const& e») {
    «catch-code»
}
```

**Surround:**
  1. The selection can be surrounded to become the try-code
  2. The selection can be surrounded to become the catch-code

##### cpp/while-getline
**Produces:**
```C++
while(std::getline(«stream»,«line»)) {
    «code»;
}
```

**Surround:**
  1. The selection can be surrounded to become the loop code

**Also includes:**
  * `<string>`


### Standard (and boost) Types
##### cpp/auto_ptr
**Produces:** `std::auto_ptr<«type»>`

**Surround:**
  1. The selection can be surrounded to become the value type

**Also includes:**
  * `<memory>`

##### cpp/auto_ptr-instance
**Produces:** `std::auto_ptr<«type»> ptr(new «type»(args));`

**Surround:**
  1. The selection can be surrounded to become the value type

**Also includes:**
  * `<memory>`

**Notes:**
  * I hesitate to called it `cpp/make_auto_ptr`

##### cpp/file
**Produces:** `«i»fstream f(«filename»);`

**Surround:**
  1. The selection can be surrounded to become the filename

**Also includes:**
  * `<fstream>`

##### cpp/list
**Produces:** `std::list<«type»> «»`

**Surround:**
  1. The selection can be surrounded to become the value type

**Also includes:**
  * `<list>`

##### cpp/map
**Produces:** `std::map<«key»,«value»> «»`

**Surround:**
  1. The selection can be surrounded to become the value type
  2. The selection can be surrounded to become the key type

**Also includes:**
  * `<map>`

##### cpp/noncopyable
**Produces:** `boost::noncopyable`

**Also includes:**
  * `<boost/noncopyable.hpp>`

##### cpp/path
**Produces:** `boost::filesystem::path`

**Also includes:**
  * `<boost/filesystem.hpp>`

##### cpp/ptr_vector
**Produces:** `boost::ptr_vector<«type»> «»`

**Surround:**
  1. The selection can be surrounded to become the value type

**Also includes:**
  * lh#dev#import#add("<boost/ptr_container/ptr_vector.hpp>")

##### cpp/set
**Produces:** `std::set<«type»> «»`

**Surround:**
  1. The selection can be surrounded to become the value type

**Also includes:**
  * <set>

##### cpp/shared_ptr
**Produces:**
  * `std::shared_ptr<«type»> «»`, in [C++11 or more](options.md#bgcpp_std_flavour)
  * `boost::shared_ptr<«type»> «»`, otherwise

**Surround:**
  1. The selection can be surrounded to become the value type

**Also includes:**
  * `<memory>` in C++11
  * `<boost/shared_ptr.hpp>` otherwise

##### cpp/string
**Produces:** `std::string «»`

**Also includes:**
  * `<string>`

##### cpp/unique_ptr
**Produces:** `std::unique_ptr<«type»>`

**Surround:**
  1. The selection can be surrounded to become the value type

**Also includes:**
  * `<memory>`

##### cpp/vector
**Produces:** `std::vector<«type»> «»`

**Surround:**
  1. The selection can be surrounded to become the value type

**Also includes:**
  * `<vector>`

##### cpp/weak_ptr
**Produces:**
  * `std::weak_ptr<«type»> «»`, in [C++11 or more](options.md#bgcpp_std_flavour)
  * `boost::weak_ptr<«type»> «»`, otherwise

**Surround:**
  1. The selection can be surrounded to become the value type

**Also includes:**
  * `<memory>` in C++11
  * `<boost/shared_ptr.hpp>` otherwise


### Standard (and boost) Functions and Idioms
##### c/assert
##### c/rand_init
##### c/realloc
##### cpp/array_size
##### cpp/b-e
##### cpp/cerr
##### cpp/cin
##### cpp/copy
##### cpp/cout
##### cpp/ends_with
##### cpp/erase-remove
##### cpp/iss
##### cpp/oss
##### cpp/sort
##### cpp/starts_with
##### cpp/static_assert

### Classes

#### Class Elements
##### cpp/assignment-operator
##### cpp/bool-operator
##### cpp/copy-and-swap
##### cpp/copy-back_inserter
##### cpp/copy-constructor
##### cpp/default-constructor
##### cpp/destructor
##### cpp/operator-binary
##### cpp/stream-extractor
##### cpp/stream-inserter

#### Class Patterns
##### cpp/abs-rel
##### cpp/class
##### cpp/enum
##### cpp/enum2
##### cpp/enum2-impl
##### cpp/singleton
##### cpp/traits

### Doxygen
##### dox/author
##### dox/code
##### dox/em
##### dox/file
##### dox/function
##### dox/group
##### dox/html
##### dox/ingroup
##### dox/since
##### dox/tt

### Miscelleanous
##### cpp/benchmark
##### cpp/otb-sug-latex
##### cpp/otb-sug-snippet
##### cpp/utf8

### Internal templates
##### cpp/internals/abs-rel-shared
##### cpp/internals/formatted-comment
##### cpp/internals/function-comment
##### cpp/internals/stream-common
##### cpp/internals/stream-implementation
##### cpp/internals/stream-signature
