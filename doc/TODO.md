# lh-cpp TO DO list

## Folding

 - [ ] if only `{`, search next line
 - [ ] `do` `while`
 - [ ] embedded `#if`

## syntax highlight

 - [ ] detect `case`
    - [X] without a `break`, or a `return`, or `continue`, or a `goto`, or `- [[fallthrough]]`
    - [ ] `break;} case` is incorrectly recognized
    - [ ] `default` is not recognized
 - [ ] detect raw pointers
 - [ ] detect calls to `malloc`/`free`/...
 - [ ] detect calls to `delete` (outside destructors)
 - [ ] detect calls to `new` (C++14)
 - [ ] detect C casts
    - [X] ignore `void foo() const`
    - [ ] ignore `decltype(auto) foo;`
    - [ ] ignore `f(12)(13)(14)`

## snippets / wizard

### class wizard

 - [ ] Doc!!
    - [X]  Options
    - [ ]  Snippets

 - [ ] Class kinds
    - [ ] CRTP
    - [ ] arithmetic class
    - [ ] clonable simpl. or interactive
    - [ ] value w/ manual copy (& swap)
    - [ ] NVI ?
    - [ ] template class
    - [ ] enum class (only tests?)
    - [ ] singleton (test)
    - [ ] Simplified way to generate new classes w/ attribs & all

 - [ ] class features
    - [ ] Check inline TODOs
    - [ ] attributes
        - [ ] use snippet if there is one with the same type name, idem for
          inheritance -> require patch on <+s:Include()+> in mu-template
    - [ ] dox functions
        - [ ] test w/ and w/o
        - [X] default constructor
        - [X] copy constructor
        - [X] init constructor
        - [X] destructor
        - [X] assignment operator
        - [X] copy'n'swap -> `swap`
        - [ ] `what`
        - [ ] attributes
        - [ ] types & classes
           - [ ] pointer means invariant
    - [ ] move contructor
    - [ ] move assignment-operator
    - [ ] Enforce «rule of all or nothing»
    - [ ] Special functions need atomic tests
        - [X] default constructor
        - [X] copy constructor
        - [X] init constructor
        - [X] destructor
        - [X] assignment operator
        - [X] copy'n'swap
        - [ ] C++11
        - [ ] w/ TBW `:MuT cpp/class attributes=foo:int,#bar:string parents=Bar,-Toto`
        - [X] `:Constructor`


### Other snippets
 - [ ] `<algorithm>` snippets should use cpp/begin-end
 - [ ] lambda
 - [ ] Check `:InsertEnum` -> tests
 - [X] Fix `:MuTemplate c/swith un deux`
 - [ ] Find a better way to pass options to `:MuTemplate` command in order to take
   advantage of cpp/class snippets. For instance:

   ```
   " +==public, #==protected, -==private
   :MuT cpp/class attributes=foo:int,#bar:string parents=Bar,-Toto
   ```

## misc

 - [ ] Register options for completion & co into menus, `:Set` and `:Toggle`
 - [ ] Have lh#dev#import rely on lh#cpp#types, or the other way around
 - [ ] `:MOVETOIMPL` doesn't work on constructors when there is an
   initialization-list
