## lh-cpp Options

### Contents

  * [Options types](#options-types)
      * [Global options: `g:`_{option-name}_](#global-options-g_option-name_)
      * [Local/project-wise options: `b:`_{option-name}_](#localproject-wise-options-b_option-name_)
      * [Project-wise options with default: `(bg):`_{option-name}_](#project-wise-options-with-default-bg_option-name_)
      * [[lh-dev options](https://github.com/LucHermitte/lh-dev#options-1): `(bg):`_[{filetype}__]{option-name}_](#lh-dev-optionshttpsgithubcomluchermittelh-devoptions-1-bg_filetype__option-name_)
  * [Option list](#option-list)
    * [`(bg):cpp_always_a_destructor_when_there_is_a_pointer_attribute'`](#bgcpp_always_a_destructor_when_there_is_a_pointer_attribute)
    * [`(bg):cpp_std_flavour` and `$CXXFLAGS`](#bgcpp_std_flavour-and-cxxflags)
    * [`(bg):({ft}_)FunctionPosArg`, `(bg):({ft}_)FunctionPosition`](#bgft_functionposarg-bgft_functionposition)
    * [`(bg):ProjectVersion`](#bgprojectversion)
    * [`(bg):({ft}_)ShowDefaultParams`, `(bg):({ft}_)ShowExplicit`, `(bg):({ft}_)ShowStatic`, `(bg):({ft}_)ShowVirtual`](#bgft_showdefaultparams-bgft_showexplicit-bgft_showstatic-bgft_showvirtual)
    * [`(bg):accessor_comment_get`, `(bg):accessor_comment_set`, `(bg):accessor_comment_ref`](#bgaccessor_comment_get-bgaccessor_comment_set-bgaccessor_comment_ref)
    * [`(bg):({ft}_)alternateSearchPath`](#bgft_alternatesearchpath)
    * [`(bg):cpp_begin_end_includes`](#bgcpp_begin_end_includes)
    * [`(bg):cpp_begin_end_style`](#bgcpp_begin_end_style)
    * [`(bg):c_menu_name`, `(bg):c_menu_priority`, `(bg):cpp_menu_name`, `(bg):cpp_menu_priority`](#bgc_menu_name-bgc_menu_priority-bgcpp_menu_name-bgcpp_menu_priority)
    * [`(bg):cpp_defaulted`](#bgcpp_defaulted)
    * [`(bg):cpp_defines_to_ignore`](#bgcpp_defines_to_ignore)
    * [`(bg):cpp_deleted`](#bgcpp_deleted)
    * [`(bg):cpp_noexcept`](#bgcpp_noexcept)
    * [`(bg):cpp_noncopyable_class`](#bgcpp_noncopyable_class)
    * [`(bg):cpp_explicit_default`](#bgcpp_explicit_default)
    * [`(bg):cpp_make_ptr`](#bgcpp_make_ptr)
    * [`(bg):cpp_noexcept`](#bgcpp_noexcept)
    * [`(bg):cpp_return_ptr_type`](#bgcpp_return_ptr_type)
    * [`(bg):cpp_root_exception`](#bgcpp_root_exception)
    * [`(bg):cpp_use_copy_and_swap`](#bgcpp_use_copy_and_swap)
    * [`(bg):cpp_use_nested_namespaces`](#bgcpp_use_nested_namespaces)
    * [`g:c_no_assign_in_condition`](#gc_no_assign_in_condition)
    * [`g:c_no_hl_fallthrough_case`](#gc_no_hl_fallthrough_case)
    * [`g:cpp_no_catch_by_reference`](#gcpp_no_catch_by_reference)
    * [`g:cpp_no_hl_c_cast`](#gcpp_no_hl_c_cast)
    * [`g:cpp_no_hl_funcdef`](#gcpp_no_hl_funcdef)
    * [`g:cpp_no_hl_throw_spec`](#gcpp_no_hl_throw_spec)
    * [`(bg):({ft}_)array_size`](#bgft_array_size)
    * [`(bg):({ft}_)dox_CommentLeadingChar`](#bgft_dox_commentleadingchar)
    * [`(bg):({ft}_)dox_TagLeadingChar`](#bgft_dox_tagleadingchar)
    * [`(bg):({ft}_)dox_author_tag`](#bgft_dox_author_tag)
    * [`(bg):({ft}_)dox_author`](#bgft_dox_author)
    * [`(bg):({ft}_)dox_brief`](#bgft_dox_brief)
    * [`(bg):({ft}_)dox_group`](#bgft_dox_group)
    * [`(bg):({ft}_)dox_ingroup`](#bgft_dox_ingroup)
    * [`(bg):({ft}_)dox_throw`](#bgft_dox_throw)
    * [`(bg):({ft}_)exception_args`](#bgft_exception_args)
    * [`(bg):({ft}_)exception_type`](#bgft_exception_type)
    * [`(bg):({ft}_)ext_4_impl_file`](#bgft_ext_4_impl_file)
    * [`(bg):({ft}_)file_regex_for_inclusion`](#bgft_file_regex_for_inclusion)
    * [`(bg):({ft}_)filename_simplify_for_inclusion`](#bgft_filename_simplify_for_inclusion)
    * [`(bg):({ft}_)gcov_files_path`](#bgft_gcov_files_path)
    * [`(bg):({ft}_)implPlace`](#bgft_implplace)
    * [`g:inlinesPlace`](#ginlinesplace)
    * [`(bg):({ft}_)includes`](#bgft_includes)
    * [`(bg):({ft}_)multiple_namespaces_on_same_line`](#bgft_multiple_namespaces_on_same_line)
    * [`(bg):({ft}_)nl_before_bracket` (deprecated)](#bgft_nl_before_bracket-deprecated)
    * [`(bg):({ft}_)nl_before_curlyB` (deprecated)](#bgft_nl_before_curlyb-deprecated)
    * [`(bg):({ft}_)pre_desc_ordered_tags`, `(bg):({ft}_post_desc_ordered_tags)`](#bgft_pre_desc_ordered_tags-bgft_post_desc_ordered_tags)
    * [`(bg):({ft}_)project_namespace`](#bgft_project_namespace)
    * [`(bg):({ft}_)tag_kinds_for_inclusion`](#bgft_tag_kinds_for_inclusion)
    * [`(bg):tags_select`](#bgtags_select)
    * [`(bg):({ft}_)template_expand_doc`](#bgft_template_expand_doc)
    * [`(bg):xsltproc`](#bgxsltproc)

### Options types

##### Global options: `g:`_{option-name}_

They are best set from the `.vimrc`;
##### Local/project-wise options: `b:`_{option-name}_
They are best set from a [`local_vimrc` file](https://github.com/LucHermitte/local_vimrc);
##### Project-wise options with default: `(bg):`_{option-name}_
Their default value can be set in the `.vimrc`, but its best to set them from a
[`local_vimrc` file](https://github.com/LucHermitte/local_vimrc);
##### [lh-dev options](https://github.com/LucHermitte/lh-dev#options-1): `(bg):`_[{filetype}__]{option-name}_

### Option list

#### `(bg):cpp_always_a_destructor_when_there_is_a_pointer_attribute'`
Boolean option that enforces the expansion of a destructor in classes that have
pointer attributes, even when it isn't required.

**Default value:** 0 (false)

**See:**
  * [`lh#cpp#snippets#_this_param_requires_a_destructor`](APID.md#lhcppsnippets_this_param_requires_a_destructor) which is used in turn by ...
  * [`lh#cpp#snippets#requires_destructor`](APID.md#lhcppsnippetsrequires_destructor) which is used in turn by ...
  * [`cpp/internals/class-skeleton.template`](snippets.md#cppinternalsclass-skeleton.template)

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
plugin manager like VAM or vim-flavor ; with dependencies unaware plugin
managers, you'll will also have to install it as well)


#### `(bg):({ft}_)FunctionPosArg`, `(bg):({ft}_)FunctionPosition`
Determines where the default implementation, for a function not yet defined,
should be placed by [`:GOTOIMPL`](features.md#gotoimpl). We are placed ...
- 0 -> ... at `cpp_FunctionPosArg` lines from the end of the file.
- 1 -> ... at the line after the first occurrence of the pattern
  `cpp_FunctionPosArg`.
  By default, we are placed after: >
```C++
/*============*/
/*===[ «» ]===*/
/*============*/
```
  That I use to insert with `:BLINES`
- 2 -> ... according the hook (user-defined VimL-function)
  `cpp_FunctionPosArg`.
  By default, we are asked for a title (actually a regex pattern), and placed
  after:
```C++
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
implementation skeleton generated for a function declaration. Same thing for
default parameter values.

Default values to all: 1 (true)

#### `(bg):accessor_comment_get`, `(bg):accessor_comment_set`, `(bg):accessor_comment_ref`
Strings to customize the comments inserted on `:ADDATTRIBUTE`.

`"%a"` will be substituted with the name of the attribute.

#### `(bg):({ft}_)alternateSearchPath`
Tells how to alternate between a source file and a header file.

Default value: `'sfr:../source,sfr:../src,sfr:../include,sfr:../inc'`

According to alternate.vim documentation:

A path with a prefix of `"wdr:"` will be treated as relative to the working
directory (i.e. the directory where vim was started.) A path prefix of `"abs:"`
will be treated as absolute. No prefix or `"sfr:"` will result in the path
being treated as relative to the source file (see sfPath argument).

A prefix of `"reg:"` will treat the pathSpec as a regular expression
substitution that is applied to the source file path. The format is:

```
reg:<sep><pattern><sep><subst><sep><flag><sep>
```

- `<sep>` seperator character, we often use one of `[/|%#]`
- `<pattern>` is what you are looking for
- `<subst>` is the output pattern
- `<flag>` can be `g` for global replace or empty

EXAMPLE: `'reg:/inc/src/g/'` will replace every instance of `'inc'` with
`'src'` in the source file path. It is possible to use match variables so you
could do something like:
```
'reg:|src/\([^/]*\)|inc/\1||'
```
(see `help :substitute`, `help pattern` and `help sub-replace-special` for more
details)

NOTE: a.vim uses `,` (comma) internally so DON'T use it in your regular
expressions or other pathSpecs unless you update the rest of the a.vim code to
use some other seperator.mentation:

#### `(bg):cpp_begin_end_includes`
Tells which header files shall be includes when expanding `begin()`/`end()`.

This option is meant to override the include files returned by
[`lh#cpp#snippets#_include_begin_end()`](API.md#lhcppsnippets_include_begin_end).

**See:** `CTRL-X_be`, `CTRL-X_cbe`, `CTRL-X_rbe`, `CTRL-X_crbe`, [`cpp/b-e` snippet](snippets.md#cppb-e)

#### `(bg):cpp_begin_end_style`
Tells which style to use to generate a couple of calls to `begin()`/`end()`:
- "`c++98`": -> `container.begin()`
- "`std`": -> `std::begin(container)`
- "`boost`": -> `boost::begin(container)`
- "`adl`": -> `begin(container)`

**See:** `CTRL-X_be`, `CTRL-X_cbe`, `CTRL-X_rbe`, `CTRL-X_crbe`, [`cpp/b-e` snippet](snippets.md#cppb-e)

#### `(bg):c_menu_name`, `(bg):c_menu_priority`, `(bg):cpp_menu_name`, `(bg):cpp_menu_priority`
These options tells where the |menu| for all C and C++ item goes.
See `:h :menu`

#### `(bg):cpp_defaulted`
String option.

**Default Value:** `= default`

**See:** API function
[`lh#cpp#snippets#defaulted()`](API.md#lhcppsnippetsdefaulted)

#### `(bg):cpp_defines_to_ignore`
Regex (default: none) that specifies which patterns (`#define`) shall be
ignored when parsing the source code to detect the current scope
(`ns1::..::nsn::cl1::.....cln`).

**See:** API functions
- [`lh#cpp#AnalysisLib_Class#SearchClassDefinition()`](API.md#lh-cpp-analysislib_class-searchclassdefinition)
- [`lh#cpp#AnalysisLib_Class#CurrentScope()`](API.md#lh-cpp-analysislib_class-currentscope)

#### `(bg):cpp_deleted`
String option.

**Default Value:** `= delete`

**See:** API function
[`lh#cpp#snippets#deleted()`](API.md#lhcppsnippetsdeleted)

#### `(bg):cpp_noexcept`
String format option (for
[`lh#fmt#printf()`](https://github.com/LucHermitte/lh-vim-lib))

**Default Value:** `noexcept%1` in C++11, `throw()` in C++98

**See:**
  * [`lh#fmt#printf()`](https://github.com/LucHermitte/lh-vim-lib))

#### `(bg):cpp_noncopyable_class`
Policy option that is used to tell how classes are made non-copyable.
  * by inheriting from a dedicated noncopyable class.
  ```
  {"name": "ITK::NonCopyable", "include": "<itkNoncopyable.h>"}
  ```
  If the class is known by the [type database](types.md) , there is no need to
  explicit
  which file shall be included:
  ```
  {"name": "boost:noncopyable"}
  ```
  * by explictly deleting copy operations (with `= delete` in C++11, or with
    declared but undefined private copy operations). This done by setting the
    option to an empty string.

**Default value:** `{"name": "boost:noncopyable"}`

**See:**
  * [Type database](types.md)
  * [`cpp/base-class.template`](snippets.md#cppbaseclass.template)
  * [`cpp/internals/class-skeleton.template`](snippets.md#cppinternalsclass-skeleton.template)

#### `(bg):cpp_explicit_default`
Boolean option that forces to explicitly add `= default` in snippets when C++11
is detected.

**Warning:** For now, this option has priority over
[`(bg):cpp_noncopyable_class`](#bgcpp_noncopyable_class). i.e. deleted copy operations will still appear even if the class inherits from a _non-copyable_ class.

**Default value:** undefined (=> ask the user)

**See:**
  * [`lh#cpp#snippets#shall_explicit_defaults()`](API.md#lhcppsnippetsshall_explicit_defaults) which encapsulates its use.
  * [`cpp/internals/class-skeleton.template`](snippets.md#cppinternalsclass-skeleton.template) which uses its result

#### `(bg):cpp_make_ptr`
String format option for [`lh#fmt#printf()`](https://github.com/LucHermitte/lh-vim-lib)).

It tells how pointers are best created. Used only from [cpp/clonable-clas.template](snippets.md#cppclonable-clas.template) snippet.

**Default Value**:
 * C++14: `std::make_unique(%3)`
 * C++11: `std::unique_ptr<%2>(new %2(%3))`
 * C++98: `std::auto_ptr<%1>(new %2(%3))`

**See:**
 * [cpp/clonable-clas.template](snippets.md#cppclonable-clas.template) which
   uses it
 * [`(bg):cpp_return_ptr_type`](#bgcpp_return_ptr_type)

#### `(bg):cpp_noexcept`
String format option (for
[`lh#fmt#printf()`](https://github.com/LucHermitte/lh-vim-lib))

**Default Value:** `override` in C++11, `/* override */` in C++98

**See:**
  * [`lh#fmt#printf()`](https://github.com/LucHermitte/lh-vim-lib))

#### `(bg):cpp_return_ptr_type`
String format option for `printf()` (TODO: migrate to [`lh#fmt#printf()`](https://github.com/LucHermitte/lh-vim-lib))).

It tells how pointers are best returned from functions. Used only from [cpp/clonable-clas.template](snippets.md#cppclonable-clas.template) snippet.

**Default Value**:
 * C++11: `std::unique_ptr<>`
 * C++98: `std::auto_ptr<>`

**See:**
 * [cpp/clonable-clas.template](snippets.md#cppclonable-clas.template) which
   uses it
 * [`(bg):cpp_make_ptr`](#bgcpp_make_ptr)

#### `(bg):cpp_root_exception`
TDB

#### `(bg):cpp_use_copy_and_swap`
Boolean option that suggest to use copy-and-swap idiom when expanding
assignment-operator snippet directly, or indirectly through value classes snippets.

**Default value:** 0 (false)

**See:**
  * [`cpp/assignment-operator.template`](snippets.md#cppassignment-operator.template) which uses it directly
  * [`cpp/internals/class-skeleton.template`](snippets.md#cppinternalsclass-skeleton.template) which uses it indirectly

#### `(bg):cpp_use_nested_namespaces`
Boolean option that enables the generation of _nested_ namespaces in C++17
codes with [`namespace` snippet](snippets.md#cppnamespace).

__Default value:__ is 1 (true).

#### `g:c_no_assign_in_condition`
Boolean option that disables syntax highlighting that detects assignments in
conditions.

__Default value:__ is 0 (false).

#### `g:c_no_hl_fallthrough_case`
Boolean option that disables syntax highlighting that detects uses of `case`
that fall through other `case`s.

This feature isn't detecting correctly situation like: `break; } case`, that
why it's disabled for the moment.

__Default value:__ is 1 (true).

#### `g:cpp_no_catch_by_reference`
Boolean option that disables syntax highlighting that detects exceptions caught
by value.

__Default value:__ is 0 (false).

#### `g:cpp_no_hl_c_cast`
Boolean option that disables syntax highlighting that detects C casts in C++.

__Default value:__ is 0 (false).

#### `g:cpp_no_hl_funcdef`
Boolean option that disables syntax highlighting that hightlight function
definitions.

__Default value:__ is 0 (false).

#### `g:cpp_no_hl_throw_spec`
Boolean option that disables syntax highlighting that detects throw
specifications in C++.

__Default value:__ is 0 (false).

#### `(bg):({ft}_)array_size`
Tells how ` [cpp/array_size`](snippets.md#cpparray_size) snippet shall behave.

This variable is meant to be a dictionary than contains the following entries:
 - `"file"`: Filename to be included.
 - `"funcname"`: Text to be included when the snippet is expanded. The special
   `"%1"` placeholder will be replaced with the array name.

__Default value:__ not defined

**See:**
- [`cpp/array_size` snippet](snippets.md#cpparray_size)

#### `(bg):({ft}_)dox_CommentLeadingChar`
Tells which character to use on each line of a Doxygen comment.

__Default value:__ `"*"`

Wrapped in API function
[`lh#dox#comment_leading_char()`](API.md#lh-dox-comment_leading_char)

#### `(bg):({ft}_)dox_TagLeadingChar`
Tells which character to use on each line of a Doxygen comment.

__Default value:__ `"*"`. Other typical value: `"!"`

Wrapped in API function
[`lh#dox#tag_leading_char()`](API.md#lh-dox-tag_leading_char)

#### `(bg):({ft}_)dox_author_tag`
Tells which tag to use to introduce authors.

__Default value:__ `"author"`.

Wrapped in API function [`lh#dox#author()`](API.md#lh-dox-author)

#### `(bg):({ft}_)dox_author`
Returns the default value to use as the author tagged in Doxygen comments.

__Default value:__ None

Wrapped in API function [`lh#dox#author()`](API.md#lh-dox-author)

#### `(bg):({ft}_)dox_brief`
Tells if `brief` tag shall be used.

__Default value:__ `"short"`.

__Other possible values:__ `"yes"/"always"/"1"`, `"no"/"never"/"0"/"short"`

Wrapped in API function [`lh#dox#brief()`](API.md#lh-dox-brief)

#### `(bg):({ft}_)dox_group`
Default Doxygen group name used in snippets and templates.

__Default value:__ the placeholder `«Project»`

**See:**
- [`dox/ingroup` snippet](snippets.md#doxingroup)
- [`dox/file` snippet](snippets.md#doxfile)
- [`cpp/class` snippet](snippets.md#cppclass)
- [`cpp/singleton` snippet](snippets.md#cppsingleton)
- [`cpp/enum2` snippet](snippets.md#cppenum2)

#### `(bg):({ft}_)dox_ingroup`
Tells if `ingroup` tag shall be used.

__Default value:__ `"0"`.

__Other possible values:__ `"yes"/"always"/"1"`, `"no"/"never"/"0"`, or a group
name to use.

Wrapped in API function [`lh#dox#ingroup()`](API.md#lh-dox-ingroup)

#### `(bg):({ft}_)dox_throw`
Tells which tag name to use to document exceptions.

__Default value:__ `"throw"`. Other typical value: `"exception"`

Wrapped in API function [`lh#dox#throw()`](API.md#lh-dox-throw)

#### `(bg):({ft}_)exception_args`
Arguments to inject in the exception called in
[`throw` snippet](snippets.md#cppthrow).

#### `(bg):({ft}_)exception_type`
Exception type to use in snippets like the
[`throw` snippet](snippets.md#cppthrow).

__Default__ is `std::runtime_error`

#### `(bg):({ft}_)ext_4_impl_file`
Tells the extension to use when [`:GOTOIMPL`](features.md#gotoimpl) generates a
new implementation skeleton for a function.

__Default__ is ".cpp".

#### `(bg):({ft}_)file_regex_for_inclusion`
Regex used by API function [`lh#cpp#tags#fetch()`](API.md#lh-cpp-tags-fetch) to
filter filenames to keep.

__Default value:__ "`\.h`"

#### `(bg):({ft}_)filename_simplify_for_inclusion`
Tells API function
[`lh#cpp#tags#strip_included_paths()`](API.md#lh-cpp-tags-strip_included_paths)
how to simplify filenames with |`fnamemodify()`|.

__Default value:__ "`:t`"

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

__Default value:__ is vim option `&path`

**See:** `<PlugCompleteIncludes>` (`i_CTRL-X_I`) and `<Plug>OpenIncludes`
(`n_CTRL_L`)

#### `(bg):({ft}_)multiple_namespaces_on_same_line`
Boolean option wrapped into API function
[`lh#cpp#option#multiple_namespaces_on_same_line()`](API.md#lh-cpp-option-multiple-namespaces-on-same-line).

__Default value:__ 1 (true)

Permits snippets like [`namespace`](snippets.md#cppnamespace) to write all names
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
In [`function-comment` snippet](snippets.md#cppinternalsinternalsfunction-comment), these |List|
options tell in which order the various documentation information are inserted
around the description the user will have to type:

The default before the user typed information is:
- "_ingroup_", "_brief_", "_tparam_", "_param_", "_return_", "_throw_", "_invariant_", "_pre_", "_post_"

The default after the user typed information is:
- "_note_", "_warning_"

#### `(bg):({ft}_)project_namespace`
Name of the project namespace used by the snippet
[`namespace`](snippets.md#cppnamespace).

__Default value:__ the placeholder `«ns»`

This is also what is returned by API function
[`lh#cpp#snippets#current_namespace()`](API.md#lh-cpp-snippets#current_namespace)
-- in that case, the default value used is an empty string.

#### `(bg):({ft}_)tag_kinds_for_inclusion`
Regex used by API function [`lh#cpp#tags#fetch()`](API.md#lh-cpp-tags-fetch) to
filter tags kind to keep.

__Default value:__ "`[dfptcs]`"

#### `(bg):tags_select`
Tags selection policy used by API function [`lh#cpp#tags#fetch()`](API.md#lh-cpp-tags-fetch).

__Default value:__ "`expand('<cword>')`".

#### `(bg):({ft}_)template_expand_doc`
Boolean option used in snippets to tell whether documentation generation is
required.

**See:**
- [`formatted-comment` snippet](snippets.md#cppinternalsformatted-comment)
- [`function-comment` snippet](snippets.md#cppinternalsfunction-comment)

#### `(bg):xsltproc`
Path to where the executable `xsltproc` is.

__Default Value:__ `xsltproc`.

This options is used by the C-ftplugin that converts PVS-studio output into a
format compatible with quickfix.

**See:** `:PVSLoad`, `:PVSIgnore`, `:PVSShow` and `:PVSRedraw`
