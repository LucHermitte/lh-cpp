## File-templates
lh-cpp & [mu-template](http://github.com/LucHermitte/mu-template) come with
tunable project headers (the default is quite bad I have to admit). You'll have
to override `templates/c/internals/c-file-header.template` to something like:

```c++
/**<+File brief line+>
 * <+lh#dox#tag('file ').s:filename+>
 * <+lh#dox#ingroup()+>
 * <+lh#dox#author()+>, creation
 * <+lh#dox#tag('copyright ')+><+strftime('%Y')+> Copyright-Holder-name
 * <+lh#dox#since('ProjectVersion')+>
 * <+lh#dox#tag('date ').strftime('%Y %b %d')+> creation
 * <p>Licence:<p> Your Project Licence
 *
 * PROJECTNAME project.
 */
```

(All the other stuff is already taken care of: include guards will be added automatically in header files, and `foo.h` will be automatically included in `foo.c(pp)`)

Then, in a local vimrc, you'll have to set the
[following options](options.md#doxygen-related-options):

 * `(bpg):({ft}_)dox_author`
 * `(bpg):({ft}_)dox_group`
 * `(bpg):ProjectVersion`

## Snippets

Several C++ snippets for classes and functions automatically generate doxygen
documentation.
See [doxygen related options](options.md#doxygen-related-options),
[class snippets](snippets.md#classes) and [Doxygen snippets](snippets.md#doxygen)
for more information on the subject.

## `:DOX`

lh-cpp provides the `:DOX` command that analyses the current function signature to build a doxygen skeleton.

The ([configurable](#configuration)) skeleton will have:
  * a brief line
  * a list of _in_, _out_, or _inout_ `@parameters`
  * a `@return` tag, if something is returned
  * `@exception` specifications if known
  * other tags like `@version`
  * etc.


### Examples

Given

```c++
std::string f(
        std::vector<std::string> & v,
        std::unique_ptr<IFoo> foo,
        int i,
        SomeType v,
        std::string const& str, int *pj);
```

`:DOX` will produce:

```c++
/**
 * «brief explanation».
 * «details»
 * @param[«in,»out] v  «v-explanations»
 * @param«[in]» foo  «foo-explanations»
 * @param[in] i  «i-explanations»
 * @param«[in]» v  «v-explanations»
 * @param[in] str  «str-explanations»
 * @param[«in,»out] pj  «pj-explanations»
 *
 * @return «std::string»
 * «@throw »
 * @pre <tt>foo != NULL</tt>«»
 * @pre <tt>pj != NULL</tt>«»
 */
std::string f(
        std::vector<std::string> & v,
        std::unique_ptr<IFoo> foo,
        int i,
        SomeType v,
        std::string const& str, int *pj);
```

You can see:

 * `«»` used as a [placeholder](https://github.com/LucHermitte/lh-brackets) to
   jump to ;
 * references interpreted as _out_ and possibly _in_ parameters ;
 * const-references interpreted as _in_ parameters ;
 * parameters of known types correctly recognized as _in_ parameters ;
 * parameters of unknown types could be proxys/pointers and thus they could act
   as _out_ parameters instead ;
 * pointer types are recognized as such, and `:DOX` suggest adding a
   precondition of non-nullity in their case ;
 * a few other tags left to the user to fill in as nothing could be deduced from
   the function signature.


### `:DOX` specific options
All [doxygen related options](options.md#doxygen-related-options) apply.

More over, `:DOX` has other dependencies:

 * `lh#dev#cpp#types#is_base_type()` can be tuned to influence whether parameters
   taken by copy are considered as _in_ parameters through:
   *  `(bpg):({ft}_)base_type_pattern`
 * `lh#dev#cpp#types#is_pointer()` is used to recognize pointer types.
