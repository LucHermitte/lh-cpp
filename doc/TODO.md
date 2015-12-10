# lh-cpp TO DO list

## Folding

 * if only `{`, search next line
 * `do` `while`
 * embedded `#if`

## syntax highlight

 * detect `case` without a `break`, or without `[[fallthrough]]`
 * detect raw pointers
 * detect calls to `malloc`/`free`/...
 * detect calls to `delete` (outside destructors)
 * detect calls to `new` (C++14)

## snippets / wizard

### class wizard

 * Doc!!
    *  Options
    *  Snippets

 * Class kinds
    * CRTP
    * artihmetic class
    * clonable simpl. or interactive
    * value w/ manual copy (& swap)
    * NVI ?
    * template class
    * enum class (only tests?)
    * singleton (test)
    * Simplified way to generate new classes w/ attribs & all

 * class features
    * Check inline TODOs
    * attributes
        * use snippet if there is one with the same type name, idem for
          inheritance
    * dox functions for special functions, attributes and other functions
        * test w/ and w/o
    * move contructor
    * move assignment-operator
    * Enforce «rule of all or nothing»

### Other snippets
 * `<algorithm>` snippets should use cpp/begin-end
 * lambda
 * Find a better way to pass options to :MuTemplate command in order to take
   advantage of cpp/class snippets. For instance:
   ```
   :MuT cpp/class attributes=foo:int,bar:string parents=Bar,Toto:private
   ```

## misc

 *  `[[` (for C++ attributes) shall not expand into `[[<cursor>]«»]«»`. See
    markdown mappings for underscore and star.
 *  Register options for completion & co into menus, `:Set` and `:Toggle`
