## lh-cpp API

### C++ Flavour

These functions permit to set the C++ flavour currently used.

The typical use case of these functions is to adapt code snippets to best fit
the idioms of the language, or to select the more standard
type/function/construct available.

#### Examples
See for instance:
- [`array_size` snippet](snippets.md#array_size)
- [`namespace` snippet](snippets.md#namespace)
- [`shared_ptr` snippet](snippets.md#shared_ptr)
- [`static_assert` snippet](snippets.md#static_assert)
- [`begin`-`end` expander](features.md#begin_end)

#### Functions
##### `lh#cpp#get_flavour()`
__Returns__: the current C++ flavour (03, 05, 11, 14, or 17)

The flavour is obtained from [`(bg)_cpp_std_flavour`, `$CXXFLAGS`, or
`$CMAKE_CXXFLAGS`](options.md#bgcpp_std_flavour-and-cxxflags).

##### `lh#cpp#use_TR1()`
__Returns__: whether TR1 (or more is supported).

This function checks [`lh#cpp#get_flavour()`](lh#cpp#get_flavour) result >=
'05'.

In order to check for TR1 and only TR1, test `lh#cpp#use_TR1() & !lh#cpp#use_cpp11()`.

##### `lh#cpp#use_cpp11()`
__Returns__: whether C++11 (or more) is supported

This function relies on [`lh#cpp#get_flavour()`](lh#cpp#get_flavour)

##### `lh#cpp#use_cpp14()`
__Returns__: whether C++14 (or more) is supported

This function relies on [`lh#cpp#get_flavour()`](lh#cpp#get_flavour)

##### `lh#cpp#use_cpp17()`
__Returns__: whether C++17 (or more) is supported

This function relies on [`lh#cpp#get_flavour()`](lh#cpp#get_flavour)

#### Tests
See [tests/lh/test-flavours.vim](tests/lh/test-flavours.vim).
