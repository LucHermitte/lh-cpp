# lh-cpp [![Build Status](https://secure.travis-ci.org/LucHermitte/lh-cpp.png?branch=master)](http://travis-ci.org/LucHermitte/lh-cpp) [![Project Stats](https://www.openhub.net/p/21020/widgets/project_thin_badge.gif)](https://www.openhub.net/p/21020)
## Features

lh-cpp is an heterogeneous suite of helpers for C and C++ programming.

It provides the following things:
  * Smart snippets for [brackets pairs](#brackets), [control statements](#code-snippets)
  * a few [templates](#templates)
  * a few [advanced wizards, and high-level features](#wizards-and-other-high-level-features) to Generate classes and singletons, to Generate ready to fill-in function comments for Doxygen, Jump to a function implementation, Search for un-implemented or undeclared functions, _etc._
  * [syntax highlighting](#syntax-highlighting) for identified counter-idioms and bad practices (catch by value, assignments in conditions, throw specifications)
  * an [API](doc/API.md) to build even more complex wizards and advanced features

  An exhaustive [list of all options](doc/options.md) is also available.

### Text insertion facilities


#### Brackets

The insertion of pair of brackets-like characters is eased thanks to [lh-brackets](http://github.com/LucHermitte/lh-brackets).

|   In mode               |   INSERT                                                            |   VISUAL                                      |   NORMAL                  |
|:------------------------|:--------------------------------------------------------------------|:----------------------------------------------|:--------------------------|
| **keys**                | Expands into ..                                                     | Surrounds the selection with ... <sup>2</sup> | Surrounds the current ... |
| `(`                     | `(<cursor>)«»`                                                      | `(<selection>)`                               | word                      |
| `[`                     | `[<cursor>]«»`                                                      | <sup>1</sup>                                  | <sup>1</sup>              |
| `[` after a `[`         | `[[<cursor>]]«»`                                                    | n/a                                           | n/a                       |
| `]` before `]]`         | close all `]]`                                                      | n/a                                           | n/a                       |
| `<localleader>[`        |                                                                     | `[<selection>]`                               | word                      |
| `{`                     | `{<cursor>}«»`<sup>3</sup>                                          | `{<selection>}`                               | word                      |
| `<localleader>{`        |                                                                     | `{\n<selection>\n}«»`                         | line                      |
| <                       | `<<cursor>>«»` after `#include`, or `template` on the same line     |                                               |                           |
| `"` (1 double quote)    | `"<cursor>"«»`                                                      | <sup>1</sup>                                  | <sup>1</sup>              |
| `""`                    |                                                                     | `"<selection>"`                               | word                      |
| `'`                     | `'<cursor>'«»`                                                      | <sup>1</sup>                                  | <sup>1</sup>              |
| `''` (2 single quotes)  |                                                                     | `'<selection>'`                               | word                      |
| `;`                     | closes all parenthesis after the cursor -- if there is nothing else |                                               |                           |

##### Notes:
  * <sup>1</sup> Not defined to avoid hijacking default vim key bindings.
  * <sup>2</sup> The visual mode mappings do not surround the current marker/placeholder selected, but trigger the INSERT-mode mappings instead.
  * <sup>3</sup> The exact behavior of this mapping has changed with release r719 (on Google Code). Now, no newline is inserted by default. However, hitting `<cr>` in the middle of a pair of curly-bracket will expand into `{\n<cursor>\n}`.
  * `«»` represents a marker/placeholder, it may be expanded with other characters like `<++>` depending on your preferences.
  * There is no way (yet) to deactivate this feature from the `.vimrc`


#### Code snippets

##### INSERT-mode snippets abbreviations
There exist, over the WWW, a lot of configurations and mappings regarding C programming. Once again you will find shortcuts for `if`, `else`, `elif`  (I know it is not a C keyword, but `else if` are), `for`, `while`, `do`, `switch`, and `main`. In C++, snippets are also provided for `try`, `catch`, and `namespace`.
What is unique is the fact that when you type `if` in insert mode, it will automatically expand into ...
```C++
if () {
}
```
... in respect of the context. I.e.: within comments or strings (delimited by single or double quotes) `if` is not expanded. If keyword characters precede the typing, `if` is not expanded as well. Thus variables like `tarif` can be used without getting any headache.


Most of these same snippets, and a few variations, are
[also provided](doc/snippets.md#control-statements) as template-files for
[mu-template](http://github.com/LucHermitte/mu-template).
This time, you just need to type the first letters of the snippet/template
name, and trigger the expansion (with `<c-r><tab>` by default). If several
snippets match (like _c/for_, _c/fori_, _cpp/fori_ and _cpp/for-iterator_ when
you try to expand `fo`), mu-template will ask you to choose which (matching)
snippet you want to expand.

##### Instruction surrounding mappings
In visual mode, `,if` wraps the selection within the curly brackets and inserts `if ()` just before. In normal mode `,if` does the same thing under the consideration that the selection is considered to be the current line under the cursor. Actually, it is not `,if` but `<LocalLeader>if,` with `maplocalleader` assigned by default to the coma `,`.

##### Expression-condition surrounding mappings
In the same idea, `<LocalLeader><LocalLeader>if` surrounds the selection with `if (` and `) {\n«»\n}«»`.

##### Other notes
All the three mode oriented mappings respect and force the indentation regarding the current setting and what was typed.

More precisely, regarding the value of the buffer relative option b:usemarks (_cf._ [lh-brackets](http://github.com/LucHermitte/lh-brackets)), `if` could be expanded into:
```C++
if () {
    «»
}«»
```

The exact style (Alman, Stroustroup, ...) regarding whether brackets are on a
new line, or not, can be tuned thanks to [lh-dev `:AddStyle` feature](http://github.com/LucHermitte/lh-dev#formatting-of-brackets-characters).

#### Miscellaneous shortcuts
Note: in all the following mappings, `,` is actually the localleader that
lh-cpp sets to the comma characcter if it isn't set already.

  * `tpl` expands into `template <<cursor>>«»` ;
  * `<m-t>` inserts `typedef`, or `typename` depending on what is before the cursor ;
  * `<m-r>` inserts `return`, and tries to correctly place the semicolon, and a placeholder, depending on what follows the cursor ;
  * `<c-x>be`, `<c-x>rbe` replace `(foo<cursor>)` with `(foo.begin(),foo.end()<cursor>)` (or `rbegin`/`rend`) ;
  * `<c->se`: attempt to fill-in a `switch-case` from an enumerated type ;
  * `,sc` | `,dc` | `,rc` | `,cc` | `,lc` surround the selection with ; `static_cast<<cursor>>(<selection>)`, `dynamic_cast`, `reinterpret_cast`, `const_cast`, or `boost::lexical_cast` ;
  * `,,sc` | `,,dc` | `,,rc` | `,,cc` try to convert the C-cast selected into the C++-cast requested ;
  * `#d` expands into `#define`, `#i` into `#ifdef`, `#e` into `endif`, `#n` into `#include` ;
  * `,0` surrounds the selected lines with `#if 0 ... #endif` ;
  * `,1` surrounds the selected lines with `#if 0 ... #else ... #endif` ;
  * `:KeepPoundIfPath 0` (or `1`) will clean a `#if 0/1...#else...#endif`
    construct to match either the true or the false path.
  * `pub` expands into `public:\n`, `pro` expands into `protected:\n`, `pri` expands into `private:\n` ;
  * `vir` expands into `virtual` ;
  * `firend` is replaced by `friend` ;
  * `<m-s>` inserts `std::`, `<m-b>` inserts `boost:` ;
  * `?:` expands into `<cursor>? «» : «»;` ;
  * `<C-X>i` will look for the symbol under the cursor (or selected) in the current ctag database and it will try to automatically include the header file where the symbol is defined.
  * `<M-i>` will look for the symbol under the cursor (or selected) in the current ctag database and it will try to automatically prepend it with its missing complete scope.
  *  `[[` and `][` and been overridden to jump to the start/end of the current
     function -- the default mappings were defined in C in mind, and they are
     unable of this. See the related `v_if` and `o_if` mappings from [lh-dev](http://github.com/LucHermitte/lh-dev/#function) -- [see the demo](blob/master/doc/screencast-select-function.gif).

#### Templates
  * All templates, snippets and wizards respect the naming convention set for
    the current project thanks to
    [lh-dev styling feature](http://github.com/LucHermitte/lh-dev#naming-conventions)
    -- see my [project style template](http://github.com/LucHermitte/mu-template/blob/master/after/template/vim/internals/vim-rc-local-cpp-style.template)
    for an idea of what is supported and possible.
  * stream inserters, stream extractor, binary operators.
  * [bool operator](doc/snippets.md#cppbool-operator): almost portable hack to
    provide a boolean operator, strongly inspired by Matthew Wilson's
    _Imperfect C++_.
  * Generation of [enums](doc/Enums.md), and of switch-case statements from enum
    definition.
  * constructors: [`copy-constructor`](doc/snippets.md#cppcopy-constructor),
    [`default-constructor`](doc/snippets.md#cppdefault-constructor),
    [`destructor`](doc/snippets.md#cppdestructor),
    [`assignment-operator`](doc/snippets.md#cppassignment-operator)
    (see `:h :Constructor`).
  * Various [standard types](doc/snippets.md#standard-and-boost-types) and
    [functions](doc/snippets.md#standard-and-boost-functions-and-idioms) (and a
    few from boost) have a snippet that'll automatically include the related
    header file there are are defined. NB: at this time, inclusions are not
    optimized as IncludeWhatYouUse would optimize them for us.
  * When a snippet/template requires header files, they will get included
    automatically (as long as the snippet specifies the headers files required)
    ; note: so far this feature cannot detect whether a required header file is
    already indirectly included through other included files.
  * Some snippets will try to detect the C++11 dialect (98/03/11/14/17) in
    order to adapt the result produced -- it will be done through the analysis
    of the [option `(bg):cpp_std_flavour`](doc/option.md#bgcpp_std_flavour-and-cxxflags) , or
    the analysis of `$CXXFLAGS`, or through the analysis of CMake `CXXFLAGS`
    variables (this will require
    [lh-cmake](http://github.com/LucHermitte/lh-cmake), and the project to be
    configured to CMake.)

I'll try to maintain an up-to-date [documentation](doc/snippets.md) of the
snippets as most of them have options.

#### Wizards and other high-level features
  * [class](doc/snippets.md#cppclass): builds a class skeleton based on the selected (simplified) semantics (value copyable, stack-based non copyable, entity non-copyable, entity clonable)
  * [singleton](doc/snippets.md#cppsingleton): my very own way to define singletons based on my conclusions on this anti-pattern -- you may prefer Loki's or ACE's solutions
  * [:DOX](doc/Doxygen.md): analyses a function signature (parameters, return type, throw specification) and provide a default Doxygenized documentation
  * [:GOTOIMPL](doc/GotoImplementation.md), :MOVETOIMPL: search and jump to a function definition from its declaration, provide a default one in the _ad'hoc_ implementation file if no definition is found
  * [:ADDATTRIBUTE](doc/Accessors.md): old facility that helps define const-correct accessors and mutator, will be reworked. [lh-refactor](http://github.com/LucHermitte/vim-refactor) provides more ergonomic mappings for this purpose.
  * [:CppDisplayUnmatchedFunctions](doc/UmatchedFunctions.md), `<c-x>u`: shows the list of functions for which there is neither a declaration, nor a definition
  * [:Override](doc/Override.md): Ask which inherited virtual function should be overridden in the current class (feature still in its very early stages)
  * `:Constructor` (that takes the following parameters: `init`, `default`, `copy`, `assign`), or `:ConstructorInit`, `:ConstructorDefault`, `:ConstructorCopy`, `AssignmentOperator`. They'll analyse the list of know attributes (from a ctags database) to generate the related construction functions.

### Syntax highlighting
  * assign in condition (bad practice)
  * catch by value (bad practice)
  * throw specifications ([do you really know what they are about, and still want them?](http://www.gotw.ca/gotw/082.htm)), BTW they have been deprecated in C++11
  * C casts in C++ (bad practice)
  * cases that fall through the next one (code smell -- disabled by default)
  * function definitions

### Miscellaneous
  * home like VC++: mappings that override `<home>` and `<end>` to mimic how these keys behave in VC++.
  * omap-param: defines the o-mappings `,i` and `,a` to select the current parameter (in a list of parameters).
  * SiR,
  * lh-cpp imports a [C&C++ Folding plugin](https://github.com/LucHermitte/VimFold4C),
    which is still experimental.
  * [lh-dev](http://github.com/LucHermitte/lh-dev), which is required by
    lh-cpp, provides a few commands like `:NameConvert` that permits to change
    the naming style of a symbol. The possible styles are: `upper_camel_case`,
    `lower_camel_case`, `snake`/`underscore`, `variable`, `local`, `global`,
    `member`, `constant`, `static`, `param`, `getter`, `setter`)

### Installation
  * Requirements: Vim 7.+, [lh-vim-lib](http://github.com/LucHermitte/lh-vim-lib), [lh-brackets](http://github.com/LucHermitte/lh-brackets), [mu-template](http://github.com/LucHermitte/mu-template), [lh-dev](http://github.com/LucHermitte/lh-dev), [alternate-lite](http://github.com/LucHermitte/alternate-lite).
  * With [vim-addon-manager](https://github.com/MarcWeber/vim-addon-manager), install lh-cpp. This is the preferred method because of the various dependencies.
```vim
ActivateAddons lh-cpp
```
  * or with [vim-flavor](http://github.com/kana/vim-flavor) which also supports
    dependencies:
```
flavor 'LucHermitte/lh-cpp'
```
  * or you can clone the git repositories (expecting I haven't forgotten anything):
```
git clone git@github.com:LucHermitte/lh-vim-lib.git
git clone git@github.com:LucHermitte/lh-tags.git
git clone git@github.com:LucHermitte/lh-dev.git
git clone git@github.com:LucHermitte/lh-brackets.git
git clone git@github.com:LucHermitte/searchInRuntime.git
git clone git@github.com:LucHermitte/mu-template.git
git clone git@github.com:tomtom/stakeholders_vim.git
git clone git@github.com:tomtom/alternate-lite.git
git clone git@github.com:LucHermitte/lh-cpp.git
```
  * or with Vundle/NeoBundle (expecting I haven't forgotten anything):
```vim
Bundle 'LucHermitte/lh-vim-lib'
Bundle 'LucHermitte/lh-tags'
Bundle 'LucHermitte/lh-dev'
Bundle 'LucHermitte/lh-brackets'
Bundle 'LucHermitte/searchInRuntime'
Bundle 'LucHermitte/mu-template'
Bundle 'tomtom/stakeholders_vim'
Bundle 'LucHermitte/alternate-lite'
Bundle 'LucHermitte/lh-cpp'
```

## Credits

Many people have to be credited:
  * the Vim & VimL gurus ;
  * the people I've stolen scripts and functions from: Stephen Riehm, Michael
    Sharpe, Georgi Slavchev, Johannes Zellner, Saul Lubkin ;
  * the people that gave me many great ideas and even feedback: Gergely Kontra,
    Leif Wickland, Robert Kelly IV [I've also stolen scripts from them] ;
  * Thomas Ribo for his feedback and features-requirements.
  * and many more that I have probably forgotten.

## License

  * Documentation is under CC-BY-SA 3.0
  * lh-cpp is under GPLv3 with exceptions. See acompagning [license file](License.md), i.e.
      * Plugin, snippets and templates are under GPLv3
      * Most code generated from snippets (for control statements, proto
        -> definition, accessors, ...) are under the License Exception
        detailled in the [license file](License.md).
      * However, code generated from the following wizards: `class`,
        `singleton`, `enum` (1&2, switch, for), `abs-rel` -> is under Boost
        Software Licence


## See also
  * [C++ tips on vim.wikia](http://vim.wikia.com/wiki/Category:C%2B%2B)
  * c.vim
  * **Project Management**: [local\_vimrc](https://github.com/LucHermitte/local_vimrc)
  * **Compilation**: [BuildToolsWrappers](http://github.com/LucHermitte/vim-build-tools-wrapper)
  * **Errors Highlighting**: syntastic, [compil-hints](http://github.com/LucHermitte/vim-compil-hints) (a non-dynamic syntastic-lite plugin that'll only highlight errors found after a compilation stage)
  * **CMake Integration**: [lh-cmake](https://github.com/LucHermitte/lh-cmake) + [local\_vimrc](https://github.com/LucHermitte/local_vimrc) + [BuildToolsWrappers](http://github.com/LucHermitte/vim-build-tools-wrapper)
  * **Refactoring**: refactor.vim, [my generic refactoring plugin](http://github.com/LucHermitte/vim-refactor)
  * **Code Completion**: [YouCompleteMe](https://github.com/Valloric/YouCompleteMe), really, check this one!, or [OmniCppComplete](http://www.vim.org/scripts/script.php?script_id=1520), or [clang\_complete](https://github.com/Rip-Rip/clang_complete)
  * **Code Indexing**: [clang\_indexer](https://github.com/LucHermitte/clang_indexer) and [vim-clang](https://github.com/LucHermitte/vim-clang), [lh-tags](http://github.com/LucHermitte/lh-tags)

