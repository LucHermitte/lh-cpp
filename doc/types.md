## lh-cpp Type DataBase

lh-cpp provides a database for most standard types and some semi-standard
types, i.e.  [Boost](http://www.boost.org) types.

### Accessing type information

#### `lh#cpp#types#get_info(type[, default-value])`
Function that returns the type information associated to `type`.

If no information is found for `type`, the `default-value` will be returned.

A type information is a dictionary object made of:
  * `"name"`: simplified name of the type (acts as a key to retrieve its
    associated information)
  * `"namespace"`: its namespace
  * `"type"`: the full type name (with template parameters)
  * `"includes`"`: list of headers file that may define the type.
  * `"typename_for_header(...)"` function.

See the [related unit test](../tests/lh/test-types.vim)

#### `lh#cpp#types#get_includes(type)`

Returns the list of header files that are know to define the `type`.


### Current database status

The best way to see which types are defined is to consult the source code of
[autoload/lh/cpp/types.vim](../autoload/lh/cpp/types.vim).
