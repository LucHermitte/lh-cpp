## lh-cpp Options

### Options types

- Global options: `g:`_{option-name}_  
  They are best set from the `.vimrc`;
- Local/project-wise options: `b:`_{option-name}_  
  They are best set from a [`local_vimrc` file](https://github.com/LucHermitte/local_vimrc);
- Project-wise options with default: `(bg):`_{option-name}_  
  Their default value can be set in the `.vimrc`, but its best to set them from a
  [`local_vimrc` file](https://github.com/LucHermitte/local_vimrc);
- [lh-dev options](https://github.com/LucHermitte/lh-dev#options-1):
  `(bg):`_[{filetype}__]{option-name}_

### Option list

#### `(bg):cpp_std_flavour` and `$CXXFLAGS`
These options are exploited by [C++ flavour decoding functions](API.md#c++-flavour)

The expected values for `(bg):cpp_std_flavour` are "03", "05" (TR1), "11", "14", or "17".
Other values will lead into Unspecified Behaviour. 

**warning:** "98" is not a valid value.

If `(bg):cpp_std_flavour` is not set, the flavour will be extracted from the
`-std=` option in `$CXXFLAGS` or else from the CMake `$CMAKE_CXXFLAGS` option.
Valid values are `-std=c++98`, `-std=c++03`, `-std=c++0x`, `-std=c++11`,
`-std=c++1y`,  `-std=c++14`, `-std=c++1z`, `-std=c++17` (the `-std=gnu++xx`
ones are also handled)

**Note:** The `$CMAKE_CXXFLAGS` option is obtained thanks to
[lh-cmake](https://github.com/LucHermitte/lh-cmake). BTW, this plugin is not
automatically installed with lh-cpp (if you are using a dependencies aware
plugin manager like VAM or vim-flavor ; with dependencies unware plugin
managers, you'll will also have to install it as well)


#### `(bg):({ft}_)FunctionPosArg`, `(bg):({ft}_)FunctionPosition`
Determines where the default implementation, for a function not yet defined,
should be placed by [`:GOTOIMPL`](features.md#gotoimpl). We are placed ...
- 0 -> ... at `cpp_FunctionPosArg` lines from the end of the file.
- 1 -> ... at the line after the first occurrence of the pattern
  `cpp_FunctionPosArg`.
  By default, we are placed after: >
  ```
  /*============*/
  /*===[ «» ]===*/
  /*============*/
  ```
  That I use to insert with `:BLINES`
- 2 -> ... according the hook (user-defined VimL-function)
  `cpp_FunctionPosArg`.
  By default, we are asked for a title (actually a regex pattern), and placed
  after:
  ```
  /*=====================*/
  /*===[ {the_title} ]===*/
  /*=====================*/
  ```
  ... That I still use to insert with |:BLINES|
- 3 -> ... nowhere, and nothing is inserted. The insertion must be done
  _manually_ thanks to [`:PASTEIMPL`](features.md#pasteimpl) .

#### `(bg):ProjectVersion`
Version of the project. Can be used in Doxygen comment through API function
[`lh#dox#since()`](API.md#lh-dox-since).

#### `(bg):({ft}_)ShowDefaultParams`, `(bg):({ft}_)ShowExplicit`, `(bg):({ft}_)ShowStatic`, `(bg):({ft}_)ShowVirtual`
Boolean options used by [`:GOTOIMPL`](features.md#gotoimpl). They tells whether
the C++ keywords `explicit`, `static` or `virtual` shall be kept in the empty
implemention skeleton generated for a function declaration. Same thing for
default parameter values.

Default values to all: 1 (true)

#### `(bg):accessor_comment_get`, `(bg):accessor_comment_set`, `(bg):accessor_comment_ref`
Strings to customize the comments inserted on `:ADDATTRIBUTE`.

"%a" will be substituted by the name of the attribute.

#### `(bg):({ft}_)alternateSearchPath`
#### `(bg):({ft}_)begin_end_style`
Tells which style to use to generate a couple of calls to `begin()`/`end()`:
- "c++98": -> `container.begin()`
- "std": -> `std::begin(container)`
- "boost": -> `boost::begin(container)`
- "adl": -> `begin(container)`

**See:** `CTRL-X_be`, `CTRL-X_cbe`, `CTRL-X_rbe`, `CTRL-X_crbe`, 

#### `(bg):c_menu_name`, `(bg):c_menu_priority`, `(bg):cpp_menu_name`, `(bg):cpp_menu_priority`
These options tells where the |menu| for all C and C++ item goes.
See `:h :menu`

#### `(bg):cpp_defines_to_ignore`
Regex (default: none) that specifies which patterns (`#define`) shall be
ignored when parsing the source code to detect the current scope
(`ns1::..::nsn::cl1::.....cln`).

**See:** API functions
- [lh#cpp#AnalysisLib_Class#SearchClassDefinition()](API.md#lh-cpp-analysislib_class-searchclassdefinition)
- [lh#cpp#AnalysisLib_Class#CurrentScope()](API.md#lh-cpp-analysislib_class-currentscope)

#### `(bg):cpp_use_nested_namespaces`
Boolean option that enables the generation of _nested_ namespaces in C++17
codes with [`namespace` snippet](snippets.md#namespace). Default is 1 (true).

#### `(bg):({ft}_)dox_CommentLeadingChar`
Tells which character to use on each line of a Doxygen comment. 

Default value: `"*"`

Wrapped in API function
[`lh#dox#comment_leading_char()`](API.md#lh-dox-comment_leading_char)

#### `(bg):({ft}_)dox_TagLeadingChar`
Tells which character to use on each line of a Doxygen comment. 

Default value: `"*"`. Other typical value: `"!"`

Wrapped in API function
[`lh#dox#tag_leading_char()`](API.md#lh-dox-tag_leading_char)

#### `(bg):({ft}_)dox_author_tag`
Tells which tag to use to introduce authors.

Default value: `"author"`.

Wrapped in API function [`lh#dox#author()`](API.md#lh-dox-author)

#### `(bg):({ft}_)dox_author`
Returns the default value to use as the author tagged in Doxygen comments.

No default value.

Wrapped in API function [`lh#dox#author()`](API.md#lh-dox-author)

#### `(bg):({ft}_)dox_brief`
Tells if `brief` tag shall be used.

Default value: `"short"`.
Other possible values: `"yes"/"always"/"1"`, `"no"/"never"/"0"/"short"`

Wrapped in API function [`lh#dox#brief()`](API.md#lh-dox-brief)

#### `(bg):({ft}_)dox_group`
Default doxygen group name used in snippets and templates. Default is the
placeholder `«Project»`

**See:**
- [`dox/ingroup` snippet](snippets.md#dox-ingroup)
- [`dox/file` snippet](snippets.md#dox-file)
- [`dox/class` snippet](snippets.md#dox-class)
- [`dox/singleton` snippet](snippets.md#dox-singleton)
- [`dox/enum2` snippet](snippets.md#dox-enum2)

#### `(bg):({ft}_)dox_ingroup`
Tells if `ingroup` tag shall be used.

Default value: `"0"`.
Other possible values: `"yes"/"always"/"1"`, `"no"/"never"/"0"`, or a group
name to use.

Wrapped in API function [`lh#dox#ingroup()`](API.md#lh-dox-ingroup)

#### `(bg):({ft}_)dox_throw`
Tells which tag name to use to document exceptions.

Default value: `"throw"`. Other typical value: `"exception"`

Wrapped in API function
[`lh#dox#throw()`](API.md#lh-dox-throw)
#### `(bg):({ft}_)exception_args`
Arguments to inject in the exception called in
[`throw` snippet](snippets.md#throw).

#### `(bg):({ft}_)exception_type`
Exception type to use in snippets like the
[`throw` snippet](snippets.md#throw).

Default is `std::runtime_error`

#### `(bg):({ft}_)ext_4_impl_file`
Tells the extension to use when [`:GOTOIMPL`](features.md#gotoimpl) generates a
new implementation skeleton for a function.

Default is ".cpp".

#### `(bg):({ft}_)file_regex_for_inclusion`
Regex used by API function [`lh#cpp#tags#fetch()`](API.md#lh-cpp-tags-fetch) to
filter filenames to keep.

Default value: "\.h"

#### `(bg):({ft}_)filename_simplify_for_inclusion`
Tells API function
[`lh#cpp#tags#strip_included_paths()`](API.md#lh-cpp-tags-strip_included_paths)
how to simplify filenames with |`fnamemodify()`|.

Default value: ":t"

#### `(bg):({ft}_)gcov_files_path`
This option tells where gcov files are expected. The default value is the
same path as the one where the current file is.

**See:** `<localleader>g` which permits to swap between a `.gcov` file and its
source.

#### `(bg):({ft}_)implPlace`
Tells where a generated accessor shall go (with `:ADDATTRIBUTE`):

- 0 -> Near the prototype/definition (Java's way)
- 1 -> Within the inline section of the header/inline/current file
- 2 -> Within the implementation file (.cpp)
- 3 -> Use the pimpl idiom (In the Todo-List)

#### `g:inlinesPlace`
Where inlines are written on `:ADDATTRIBUTE`

- 0 -> In the inline section of the header/current file
- 1 -> In the inline section of a dedicated inline file

#### `(bg):({ft}_)includes`
Option used by the C-ftplugin that completes the names of files to include.
The options tells which directories shall be searched.

Its default value is vim option `&path`

**See:** `<PlugCompleteIncludes>` (`i_CTRL-X_I`) and `<Plug>OpenIncludes`
(`n_CTRL_L`)

#### `(bg):({ft}_)multiple_namespaces_on_same_line`
Boolean option wrapped into API function
[`lh#cpp#option#multiple_namespaces_on_same_line()`](API.md#lh-cpp-option-multiple-namespaces-on-same-line).

Default value: 1 (true)

Permits snippets like [`namespace`](snippets.md#namespace) to write all names
on a same line (when _nested namespaces_ aren't supported). i.e:

```C++
// If true
namespace ns1 { namespace ns2 {
} } // namespaces ns1::ns2

// If false
namespace ns1 {
namespace ns2 {
} // namespace ns1::ns2
} // namespace ns1
```

#### `(bg):({ft}_)nl_before_bracket` (deprecated)
#### `(bg):({ft}_)nl_before_curlyB` (deprecated)
#### `(bg):({ft}_)pre_desc_ordered_tags`, `(bg):({ft}_post_desc_ordered_tags)`
In [`function-comment` snippet](snippets.md#function-comment), these |List|
options tell in which order the various documentation information are inserted
around the description the user will have to type:

The default before the user typed information is:
- "ingroup", "brief", "tparam", "param", "return", "throw", "invariant", "pre", "post"

The default after the user typed information is:
- "note", "warning"

#### `(bg):({ft}_)project_namespace`
Name of the project namepace used by the snippet
[`namespace`](snippets.md#namespace).

The default is the placeholder `«ns»`

This is also what is returned by API function
[`lh#cpp#snippets#current_namespace()`](API.md#lh-cpp-snippets#current_namespace)
-- in that case, the default value used is an empty string. 

#### `(bg):({ft}_)tag_kinds_for_inclusion`
Regex used by API function [`lh#cpp#tags#fetch()`](API.md#lh-cpp-tags-fetch) to
filter tags kind to keep.

Default value: "[dfptcs]"

#### `(bg):tags_select`
Tags selection policy used by API function [`lh#cpp#tags#fetch()`](API.md#lh-cpp-tags-fetch).

Default value: "`expand('<cword>')`".

#### `(bg):({ft}_)template_expand_doc`
Boolean option used in snippets to tell whether documentation generation is
required.

**See:**
- [`formatted-comment` snippet](snippets.md#formatted-comment)
- [`function-comment` snippet](snippets.md#function-comment)

#### `(bg):xsltproc`
Path to the executable `xsltproc` is. Default is `xsltproc`.

This options is used by the c-ftplugin that converts PVS-studio output into a
format compatible with quickfix.

**See:** `:PVSLoad`, `:PVSIgnore`, `:PVSShow` and `:PVSRedraw` 
