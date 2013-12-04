*lh-cpp-readme.txt*     C & C++ ftplugins short presentation (v2.0.0b4)
                        For Vim version 7.x.    Last change: 04th Dec 2013

                        By Luc Hermitte
                        <hermitte {at} free {dot} fr>


------------------------------------------------------------------------------
This a very short guide to the C&C++ ftplugin suite lh-cpp

Contents~
|lh-cpp-features|       The features proposed by the ftplugins
|lh-cpp-first-steps|    Your first steps with these ftplugins
|Files-from-lh-cpp|     The files that compose the archive
|add-local-help|        Instructions on installing this file (:helptags %:h)


------------------------------------------------------------------------------
                                                        *lh-cpp-features*
Features~
|C_settings|                    Various settings
|brackets-for-C|                Bracketing system
|C_control-statements|          Control statements for C editing (for, if, etc)
  |C_switch_enum|                 Expands an enum into a switch statement
|C_snippets|                    Other C snippets and shortcuts
|C++_control-statements|        Control statements for C++ editing (try, ...)
|C++_accessors|                 C++ accessors & some templates skeletons
|C++_jump_implementation|       Jumping to functions-implementation
|C++_function_doxygenation|     Doxygenize a function prototype
|C++_templates|                 Skeletons, snippets, and wizards provided
  |C_snippet_realloc|
  |C++_template_new|
  |C++_template_class|
  |C++_template_default-constructor|
  |C++_template_copy-constructor|
  |C++_template_copy-and-swap|
  |C++_template_assignment-operator|
  |C++_template_destructor|
|C++_Override|                  Function overriding helper
|C++_unmatched_functions|       Search for declared ad undefined functions (or
                              the other way around)
|C++_inspection|                Inspection of various properties (children,
                              ancestors, ...)
|C++_options|                   Options for different features (i.e. ftplugins)
 ...|C++_doxygen-options|       Options related to Doxygen.
|lh-cpp_API|                    Functions available to write your own
                              ftplugins and templates.
 ...|lh#cpp#dox#|               Doxygen related functions

|mu-template.txt|               Gergely Kontra's mu-template
|previewWord.vim|               Georgi Slavchev's previewWord.vim
|C_folding| |C++_folding|         C & C++ folding
|search-in-runtimepath|         Searching in various directories lists

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                        *C_settings*
    Various settings from c_set.vim~
    File:       ftplugin/c/*c_set.vim*

    Vim-options~
        'formatoptions' is set `to' `croql'
        'cindent'       is set.
        'cinoptions'    is set to ``g0,t0'' 
                                (``g0,t0,h1s'' for C++ with |cpp_set.vim|).
        'define'        is set to recognize defines and constants.
        'comments'      is set to ``sr:/*,mb:*,exl:*/,://''
        'isk'           is completed with ``#'', thus ``#if'' is considered to
                        be a keyword, and looses ``-'' this ``ptr->foo'' is
                        correctly separated.
        'ch'            is set to 2.
        'showmode'      is unset.
        'dictionary'    is completed with ``{rtp}/ftplugin/c/word.list''.
        'complete'      is completed with ``k'', and looses ``i'' (to prevent
                        interminable header-file parsing)
        'localleader'   is set to ``,'', unless it is already defined.
        'suffixesadd'   is completed with ``.h'' and ``.c''.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                        *brackets-for-C*
Bracketing system~
Files:      |bracketing.base.vim| & |common_brackets.vim|
Requires:   |lh-brackets| (needed); |Triggers.vim| (supported)
Help:       <http://code.google.com/p/lh-vim/wiki/lhBrackets>
            <http://code.google.com/p/lh-vim/wiki/lhCpp#Brackets>
License:    The generated code is under license exception to GPLv3
            <http://code.google.com/p/lh-vim/wiki/License>

Options:    
    |b:usemarks|                                    (0/[1]) 
        to enable the insertion of |markers|.
    |g:marker_prefers_select|                       (0/[1]) 
        select or echo the text within marker.
    |g:marker_select_empty_marks|                   (0/[1]). 
        select or delete markers on !jump!
    and many more that are pointless here.

Mappings defined in this particular configuration:
    |!mark!|    inserts a |marker| -- default: «»
    |!jump!|    jumps to the next marker
    |!jumpB!|   jumps to the previous marker
    |<M-Ins>|   shortcut to !mark!    ; can be redefined
    |<M-Del>|   shortcut to !jump!    ; can be redefined
    |<M-S-Del>| shortcut to !jumpB!   ; can be redefined
 imaps
    {       {\n\n}  + |markers| (if |b:usemarks|==1) and cursor positioned
    #{      {}      + |markers| (if |b:usemarks|==1) and cursor positioned
    (       ()      + |markers| (if |b:usemarks|==1) and cursor positioned
    [       []      + |markers| (if |b:usemarks|==1) and cursor positioned
    "       ""      + |markers| (if |b:usemarks|==1) and cursor positioned
    '       ''      + |markers| (if |b:usemarks|==1) and cursor positioned
    <F9>    toggles the 4 previous mappings   ; requires |Triggers.vim|
    <M-F9>  toggles the value of |b:usemarks| ; requires |Triggers.vim|

    <       expands into <!cursor!>!mark! if the opening angle-bracket
        immediatelly follows ``#include'', a C++ cast, ``template'' or
        ``typename''. Otherwise, it is not expanded.

 n&vmap:
    {, (, '', "", <localleader>[
       Surround the current selection (or word in |Normal-mode|) with the
       bracket-like character used in the mapping.
    <localleader>{ 
       Insert a pair of curly brackets around the current line (/visual
       selection). It is done in respect of |b:usemarks|.

+ some mappings from auxtex.vim to manipulate brackets
    *<M-b>x* *<M-b><Delete>* : delete a pair of brackets
    *<M-b>(*  replaces the current pair of brackets with parenthesis
    *<M-b>[*  replaces the current pair of brackets with square brackets
    *<M-b>{*  replaces the current pair of brackets with curly brackets
    *<M-b><*  replaces the current pair of brackets with angle brackets
    *<M-b>\*  toggles the backslash on a pair of brackets

NB: The brackets mappings only insert the markers when |b:usemarks|==1,
    and outside comments and string contexts.
    They are buffer relative.
        
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                    *C_control-statements*
C Control statements~
File:       ftplugin/cpp/|c_snippets.vim|
Requires:   |lh-brackets| (needed)
Help:       <http://code.google.com/p/lh-vim/wiki/lhCpp#Code_snippets>
License:    The generated code is under license exception to GPLv3
            <http://code.google.com/p/lh-vim/wiki/License>

Mappings and abbreviations defined: [always buffer-relative]
 abbr: if    if {\n}        + |markers| (if |b:usemarks|==1)       *C_if*
                            + cursor positioned
 abbr: elif   else if {\n}      + ...                          *C_elif*
 abbr: else   if {\n}           + ...                          *C_else*
 abbr: while  while {\n}        + ...                          *C_while*
 abbr: do     do{\n}while()     + ...                          *C_do*
 abbr: for    for(;;) {\n}      + ...                          *C_for*
 abbr: switch switch {\n}       + ...                          *C_switch*
 abbr: Ymain  int main() \n{\n} + ...                          *C_main*

 n&vmap: <localleader>if , elif, else, wh, for & main
        Insert the control-statement around the current line (/visual
        selection). It is also done in respect of |b:usemarks|.

 n&vmap: <localleader><localleader>if , elif, wh, for
        The current line (/visual selection) is used as the
        conditional expression of the control statement inserted.  It is
        also done in respect of |b:usemarks|.

Options:
    * Regarding the control statements (|C_if|, |C_else|, |C_while|, 
      |C_for|, |C_switch|), a newline will be inserted before:
      - the open parenthesis    if *g:c_nl_before_bracket* == 1
      - the open curly-bracket  if *g:c_nl_before_curlyB*  == 1
      [By default, these options are considered equal to 0.]

NB: * |b:usemarks| is still taken into account.
    * Works even if the bracketing system is not installed or deactivated
      (with <F9>).
    * Not tested with other bracketing systems than the one I propose.
    * Within comment-, string- or character-context, the abbreviations are
      not expanded. Variables like 'tarif' can be used with no problem.
    * These abbreviations will not insert undesired white-space.
    * Also contains my different settings.
    * To tune more precisely how the lines are indented, check 'cindent'.
    * If the visual selection exactly matches a |marker|, then the
      visual-mode mappings will result in the use of the equivalent
      abbreviations.
    * The normal- and visual-modes mappings do not respect
      |g:c_nl_before_bracket| and |g:c_nl_before_curlyB|.
     
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                    *C_switch_enum*
                                                    *<Plug>SwitchEnum*
Mapping: ~
   *i_CTRL-X_se* expands the name of the enum (type, or variable) before the
   cursor into a switch statement.

   Given: >
        enum E { NO, YES, MAX__ };
        E var;

        var<c-x>se
<   will expand into: >
        switch (var)
        {
            case YES: 
                «YES-code»;
                break;
            case NO:
                «NO-code»;
                break;
            default:
                «default-code»;
                break;
        }

Requirements:~
This feature requires a ctags database where to fetch the enum definition.
It also requires |lh-dev|, and |mu-template|.

Known issues:~
At this time, the plugin is not capable of respecting the declaration order of
the enumerated values. The switch will iterate on the enumerated values
following the lexical order.

Options~
The default mapping to |i_CTRL-X_se| can be overridden with for instance: >
    imap <buffer> <silent> <leader>se <Plug>SwitchEnum

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                    *C_snippets*
Other snippets and shortcuts from c_snippets.vim~
File:       ftplugin/c/*c_snippets.vim*
License:    The generated code is under license exception to GPLv3
            <http://code.google.com/p/lh-vim/wiki/License>

Mappings and abbreviations~
    *#n*      expands into "#include", in respect of the context.
    *#d*      expands into "#define", in respect of the context.
    *#i*      expands into "#ifdef", in respect of the context.
    *#e*      expands into "#endif", in respect of the context.
    *<M-r>*   expands into "return ;"
    *?:*      expands into "?...:...;"
    *<M-v>*   surrounds the selection with /*...*/
    <localleader>0 surrounds the line selected with #if 0...#endif
    <localleader>1 surrounds the line selected with #if 0...#else\n#endif

To prevent these mappings and abbreviations to be defined, set
|g:lh_cpp_snippets| to 0.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                    *C++_control-statements*
C++ Control statements and other shortcuts~
File:       ftplugin/cpp/*cpp_snippets.vim*
Requires:   |C_control-statements|
Help:       <http://code.google.com/p/lh-vim/wiki/lhCpp#Code_snippets>
License:    The generated code is under license exception to GPLv3
            <http://code.google.com/p/lh-vim/wiki/License>

Mappings and abbreviations defined: [always buffer-relative]
 abbr: namespace namespace {\n} + markers and cursor pos.    *C_namespace*
       expanded only in it does not follow ``using''
 abbr: try    try{\n}catch(){\n} + markers and cursor pos.   *C_try*
 abbr: catch  catch(){\n}    + markers and cursor positioned *C_catch*
 abbr: pub    public:                                        *C_pub*
 abbr: pro    protected:                                     *C_pro*
 abbr: pri    private:                                       *C_pri*
 abbr: tpl    template<>                                     *C_tpl*
 abbr: virt   virtual                                        *C_virt*
 abbr: delate delta
 abbr: firend friend
 imap: <M-s> std::                                           *Ci_META-s*
 imap: <M-b> boost:: or boost/                               *Ci_META-b*
 imap: <M-l> luc_lib::                                       *Ci_META-l*
            (very personal mapping you won't need)

 imap: <M-t> "typedef"/"template" depending on the context   *Ci_META-t*
 imap: <c-x>be                                               *Ci_CTRL-X_be*
 imap: <c-x>rbe                                              *Ci_CTRL-X_rbe*
        Duplicates the text within parenthesis, add a comma between the two
        occurrences, and append '.begin()' and '.end()' (or 'rbegin()',
        'rend()') to each.

 imap: /*<space>    /** */!mark!                             *C++_comments*
 imap: /*!          /**\n*/!mark!

 n&vmap: <localleader>try , catch , ns (-> "namespace{\n}")
        Insert the previous text around the current line (/visual
        selection). It also done in respect of |b:usemarks|.

 n&vmap: <localleader><localleader>catch
        The current line (/visual selection) is used as the formal parameter
        of the catch-block. It is also done in respect of |b:usemarks|.

                                                *n_,dc* *n_,rc* *n_,sc* *n_,cc*
                                                *v_,dc* *v_,rc* *v_,sc* *v_,cc*
 n&vmap: <localleader>dc, rc, sc, cc
        Insert ``dynamic_cast'', ``reinterpret_cast'', ``static_cast'' or
        ``const_cast'', the selected text is used as the expression to
        coercise. The cursor is placed between the angle brackets.

 n&vmap: <localleader><localleader>dc, rc, sc, cc
        Insert ``dynamic_cast'', ``reinterpret_cast'', ``static_cast'' or
        ``const_cast'', the selected text is used as the type expression of
        the result of a coercion. The cursor is placed between the
        parenthesis.

NB: * All the remarks from |C_control-statements| apply.
    * The options |g:c_nl_before_bracket| and |g:c_nl_before_curlyB| apply
      to |C_namespace|, |C_try| and |C_catch|.

To prevent these mappings and abbreviations to be defined, set
|g:lh_cpp_snippets| to 0.


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                        *C++_accessors* *getter* *setter*
C++ accessors & some templates~
Files:      *cpp_BuildTemplates.vim* , *cpp_InsertAccessors.vim*
Help:       <http://code.google.com/p/lh-vim/wiki/lhCpp_Accessors>
License:    The generated code is under license exception to GPLv3
            <http://code.google.com/p/lh-vim/wiki/License>
Requires:   |a.vim| (optional)
Options:    |C++_accessors_options|

Commands:           Associated mappings
    *:ADDATTRIBUTE*          *;AA*      (do it, cursor on the "private" line)
        Interactive procedure to add a new set of attribute + its
        optimized const-correct getter & setter.
        See also: ||refactor-extract-getter| and ||refactor-extract-setter|.

    *:HEADER* {name}         *;HE*      Header file template
        Deprecated, prefer |C++_file-template|
    *:CLASS*  {name}         *;CL*      Class declaration template
        Deprecated, prefer |C++_class-template|
    *:BLINES* {name}         *;BL*      Inserts rulers
    *:GROUP*  {name}         *;GR*      Inserts a Doc++ group
    *:MGROUP* {name}         *;MGR*     Inserts a Doc++ group + a ruler
    *:REACHINLINE* {name}    *;RI*      Reaches the place where inlines are
                                    defined
                                                *C++_accessors_options*
Options:
    See |lhdev-naming| options.

    *(b|g):{ft_}accessor_comment_get* *(b|g):{ft_}accessor_comment_proxy_get*
    *(b|g):{ft_}accessor_comment_set* *(b|g):{ft_}accessor_comment_proxy_set*
    *(b|g):{ft_}accessor_comment_ref* *(b|g):{ft_}accessor_comment_proxy_ref*
        => strings to customize the comments
        "%a" will be substituted by the name of the attribute.

    *(b|g):{ft_}implPlace* where accessor-definitions occur 
        0 -> Near the prototype/definition (Java's way)
        1 -> Within the inline section of the header/inline/current file
        2 -> Within the implementation file (.cpp)
        3 -> Use the pimpl idiom (In the Todo-List)
    *g:inlinesPlace* where inlines are written 
        0 -> In the inline section of the header/current file
        1 -> In the inline section of a dedicated inline file

    |g:c_nl_before_curlyB|                    : newline before '{'

Notes:
    * Everything here match my preferences regarding code presentation
    * The |:ADDATTRIBUTE| command (that inserts an attribute, its accessor
      and its mutator -- getter and setter) requires that some formating
      is respected -- you will certainly have to adapt it.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *C++_jump_implementation*
Jumping to functions-implementation~
Help:       <http://code.google.com/p/lh-vim/wiki/lhCpp_GotoImplementation
License:    The generated code is under license exception to GPLv3
            <http://code.google.com/p/lh-vim/wiki/License>
Inspiration:Leif Wickland's VIM TIP #135, and Robert Kelly IV for many
            features.

Commands:               Associated mappings
    *:GOTOIMPL* {options}     *n_;GI*
                      *i_CTRL-X_GI*     [Insert mode default mapping]
                        <M-LeftMouse>
        Go to the implementation of the current function, if the
        implementation does not exist yet, a default one will be provided.
        To change the keybindings:  *<Plug>GotoImpl*

    *:MOVETOIMPL* {options}   *n_;MI*
                      *i_CTRL-X_MI*     [Insert mode default mapping]
        Move the implementation of the current inline function.
        To change the keybindings:  *<Plug>MoveToImpl*

    *:PASTEIMPL*              *n_;PI*
                      *i_CTRL-X_PI*     [Insert mode default mapping]
                        <M-RightMouse>
        Insert the function-implementation on the next line
        To change the keybindings:  *<Plug>PasteImpl*

Special features:
    * Supports member and non-member functions ;
    * Scopes due to nested classes or namespaces are correctly supported:
      + function names are produced according to the current (where the
        function is declared) scope (nested classes + namespaces),
      + jumps and insertions respect the current (where the insertion
        happens) namespace ;
    * Comments from the declaration stripped ;
    * Comments in the implementation ignored (jumping only feature) ;
    * Parameters names can be changed (as they have no incidence on the
      signature) ;
    * "virtual", "static" and default argument values can be commented ;
    * The insertion of the default implementation can be automated and
      deeply customized ;
    * Not allowed to jump/insert to the implementation of pure virtual
      functions ("virtual t f(...) = 0;") ;
    * Will refuse to jump/insert from anything else that functions-
      declarations. Still lazy ; may hang on member variables.
    * Check the history for other minor details.

Options:
    *(bg):[{ft}_]ext_4_impl_file*             (text)
        This option specifies the default file-extension of the file where the
        function definition should go.
        Can be overridden on the fly with: :GOTOIMPL {ext}
    *(bg):[{ft}_]ShowVirtual*             (0/[1])
        When true, if the function is virtual, then the comment
        /*virtual*/ will be added at the beginning of the proposed
        implementation.
        Can be overridden on the fly with: :GOTOIMPL ShowVirtual0/1
    *(bg):[{ft}_]ShowStatic*              (0/[1])
        When true, if the function is static, then the comment /*static*/
        will be added at the beginning of the proposed implementation.
        Can be overridden on the fly with: :GOTOIMPL ShowStatic0/1
    *(bg):[{ft}_]ShowExplicit*            (0/[1])
        When true, if the function is explicit then the comment /*explicit*/
        will be added at the beginning of the proposed implementation.
        Can be overridden on the fly with: :GOTOIMPL ShowExplicit0/1
    *(bg):[{ft}_]ShowDefaultParams*       (0/[1]/2/3)
        Determines if a comment will be added for every parameter having a
        default value -- according to the function-signature.
            0 -> No reminder
            1 -> /* = {theDefaultValue} */
            2 -> /*={theDefaultValue}*/
            3 -> /*{theDefaultValue}*/
        Can be overridden on the fly with: :GOTOIMPL ShowDefaultParam0/1
    *(g):[{ft}_]FunctionPosition* ([0]/1/2/3) & *(g):[{ft}_]FunctionPosArg* ([0])
        Determines where the default implementation, for a function not yet
        defined, should be placed. We are placed ...
            0 -> ... at |g:cpp_FunctionPosArg| lines from the end of the
                 file.
            1 -> ... at the line after the first occurrence of the pattern
                 |g:cpp_FunctionPosArg|.
                 By default, |cpp_options.vim| places us after: >
                    /*============*/
                    /*===[ «» ]===*/
                    /*============*/
<                       ... That I use to insert with |:BLINES|
            2 -> ... according the hook (user-defined VimL-function)
                 |g:cpp_FunctionPosArg|.
                 By default, |cpp_options.vim| asks us for a title
                 (actually a regex pattern), and places us after: >
                    /*=====================*/
                    /*===[ {the_title} ]===*/
                    /*=====================*/
<                       ... That I still use to insert with |:BLINES|
            3 -> ... nowhere, and nothing is inserted. The insertion must
                 be done _manually_ thanks to |:PASTEIMPL|.

        Note: If the placement fails, it will still be possible to insert
        manually the default function-implementation thanks to |:PASTEIMPL|.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                            *C++_templates*
C++ skeletons and wizards~

lh-cpp provides several template-files expanded thanks to |mu-template|.

                                                    *C++_template_new*
New C/C++ file~
When a new C or C++ (non-existing) file is opened, |mu-template| provides a
default skeleton. 

... new header file~
A header-file will have a header (where one's can put copyright information,
RCS tags, etc.), anti-reinclusion guards. Some parts of what is generated can
be globally overridden, or overridden only for project specific needs ; see
|MuT-paths-override|. 
The variation points are:
- the template-file {rtp}/template/c/internals/c-file-header.template
  where file header is specified ;
- the template-file {rtp}/template/c/internals/c-header-guard.template
  where the computation of the header guard name, *s:guard* , is done ;
- |b:sources_root| that can be used to specify the project root directory --
  this information is used by the default header-guard name policy. 

... new implementation file~
An implementation-file will have a header, and if a header-file (and even an
inline (.inl) file) file with the "same" name is found, it will be included.
The variation points are:
- the template-file {rtp}/template/c/internals/c-file-header.template
  where file header is specified ;
- the template-file {rtp}/template/c/section-sep.template that is used to
  specify the format of section header ;
- the template-file {rtp}/template/c/internals/c-header-content.template
  that is meant to be overridden if some default content is always expected
  like a C++ namespace.
- |(bg):cpp_included_paths|, |List| that is used to search for the related
  header-file to include.


                                                    *C++_template_class*
New C++ class~
This skeleton-file acts as a wizard.
It first asks the user the name of the new C++ class if it hasn't specified
(by default it's the name of the current file).  Then it asks what semantics
the class shall have:
- value-semantics (stack-based, copyable, assignable, and may be comparable) ;
- Stack-based semantics, but non copyable ;
- Entity semantics, and non copyable ;
- Entity semantics, but clonable.

See the following articles if you want some more C++ insights on the
implications of the question: 
- <http://akrzemi1.wordpress.com/2012/02/03/value-semantics/>
- [French]
  <http://cpp.developpez.com/faq/cpp/?page=classes#CLASS_forme_canonique>

Accordingly to user's choice, default functions for the class will be
generated, or inhibited.

If you'd rather have more control over what is done, use instead the templates
|C++_template_copy-and-swap|, |C++_template_copy-constructor|,
|C++_template_assignment_operator|.

To-do: |C++_template_destructor| that detects visibility to add <+virtual+> or
nothing.
To-do: support C++11 copy inhibition syntax
To-do: support C++11 move-construction and move-assignement.

The variation points are:
- |(bg):[{ft}_]dox_CommentLeadingChar|, |(bg):[{ft}_]dox_TagLeadingChar|,
  |(bg):[{ft}_]dox_brief|, |(bg):[{ft}_]dox_ingroup|,
  |(bg):[{ft}_]dox_author_tag|, |(bg):[{ft}_]dox_author|, 
- |(bg):dox_group|
  NB: As I've reached the conclusion that everything shall be sorted into
  doxygen groups, I force the presence of this doxygen tag.
- CppDox_ClassWizard()
- the template-file {rtp}/template/cpp/internals/function-comment.template
  that is used to order the documentation tags associated to generated
  functions. This template file introduced its own variation points:
  - *(bg):[{ft_}]pre_desc_ordered_tags* 
    default= ["ingroup", "brief", "param", "return", "throw", "invariant", "pre", "post"]
  - *(bg):[{ft_}]post_desc_ordered_tags*
    default= ["note", "warning"]
  - |(bg):[{ft_}]template_expand_doc|
  - the template-file {rtp}/template/cpp/internals/formatted-comment.template
    that is used to convert the final list of documentation tag into the
    embedded comments. The default format used is Doxygen format.

                               *:Constructor*
                               *:ConstructorInit*
                               *:ConstructorDefault*  *C++_template_default-constructor*
                               *:ConstructorCopy*     *C++_template_copy-constructor*
                                                    *C++_template_copy-and-swap*
                               *:AssignmentOperator*  *C++_template_assignment-operator*
                                                    *C++_template_destructor*
Snippets for constructors and related functions~
Various |mu-template| snippets are provided to insert construction/destruction related functions.
All detect the current class-name, they can receive some other parameters. (to
be documented)
They will apply naming conventions from |lh#dev#naming|
See |C++_template_class| documentation for a more complete list of the
parameters and other variation points involved in these snippets.

They can also be run from |:Constructor| (or the other commands). In that
case, a ctag database will be used to find which attributes the current class
is made of in order to fill the implementation of the function as weel as we
can.

TODO: rely of libclang when ctags in not used

                                                    *C_snippet_realloc*
Snippet for realloc()~
realloc() is a tricky C function that most C developers mis-use. One shall
never write: >
    p = realloc(p, new_size);
but instead: >
    T* p_temp = realloc(p, new_size);
    if (!p_temp) {
        free(p) ;
	+ other reset ;
	+ error notification ;
	return false;
    }
    p = p_temp;
Hence this snippet aimed at simpliying our life.

|lh-refactor| defines |:FixRealloc| that corrects the first snippet above by
the second one. -- this command is likelly fall back in |lh-cpp| scope in
future versions.


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                          *C++_Override*
                                                          *:Override*  
Function overridding helper~
>
    :Override

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                *C++_unmatched_functions*
                                                *:CppDisplayUnmatchedFunctions*
Search for declared ad undefined functions (or the other way around)~
>
    :CppDisplayUnmatchedFunctions

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                        *C++_inspection*
Inspection of various properties~
*:Ancestor* [classname]
*:Children* [!] [namespace] [classname]

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                            *C++_options*
C++ options~
lh-cpp supports many options directly, or indirectly (through |mu-template|
for instance).

                                                *C++_options_global*
Some options are global, i.e. they applies on the current vim session for all
open files. They are implemented as vim |global-variable|s.

                                                *C++_options_local*
Other options are local, i.e. restricted to each buffer. This does not prevent
us to have an option having the same value in several buffers, however
changing the value of the option in one buffer won't affect the value of the
option in other buffers. They are implemented as vim |buffer-variable|s. 
Semantically speaking, there are two kind of local options: 
- options specific to a filetype ;
- options specific to a project.
NB: lh-cpp doesn't use the other kinds of vim variables as options
(|window-variable|s, |tabpage-variable|s).

                                            *C++_options_local_filetype*
These options are meant to be set in |ftplugins|. Actually they are of two
natures: vim |options| (indenting settings, etc.), and vim |buffer-variable|s
((ft)plugins settings).
Most of lh-cpp options are expected to begin with "cpp_". As a consequence,
they won't actually clash with equivalent settings from other filetypes.

Other plugins I'm maintaining (see |lh-refactor| for instance) support
multi-filetype options, which support default values that can be overridden for
specific filetypes (by appending "{ft}_" to the name of the options when
setting them), or specific projects. See |lhdev-filetype| for the actual
naming policy.

                                            *C++_options_local_project*
These options are meant to be set by plugins oriented to the management of
projects. Typical examples are |project.vim|, or one of the numerous
|local_vimrc| plugin (I'm also maintaining one...).
Once again one can set vim |options| or |buffer-variable|s in the
buffer specific zone of its |local_vimrc|.


                                            *C++_options_local_conclusion*
Default options for a specific filetype shall be defined as |buffer-variable|s
(/vim local |options|) in a |ftplugin| placed in $HOME/.vim/ftplugin/cpp/ (or
/c/) (or the windows equivalent location, see 'runtimepath').

Project specific settings shall override the previous default settings in
|local_vimrc|s.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                            *C++_doxygen-options*
C++ options for doxygen~

*(bg):[{ft}_]dox_CommentLeadingChar* Character used at ???; default: "*"
*(bg):[{ft}_]dox_TagLeadingChar*     Character used to introduce tags: "!"/"[@]"
*(bg):[{ft}_]dox_brief*              Shall we have a @brief tag?  -> yes/no/[short]
*(bg):[{ft}_]dox_ingroup*            Shall we have a @ingroup tag?  -> yes/[no]
*(bg):dox_group*                     Name of the doxygen group.
*(bg):[{ft}_]dox_author_tag*         Name of the tag to use: ["author"]/"authors"
*(bg):[{ft}_]dox_author*             Name(s) of the author(s).

*(bg):[{ft_}]template_expand_doc* is a boolean option (default: 1) 
    Tells whether embedded documentation (as comments) shall be generated when
    template-files are expanded.
    Used by: 
    - the template-file {rtp}/template/cpp/internals/function-comment.template
    - the template-file {rtp}/template/cpp/internals/formatted-comment.template
 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Michael Sharpe's a.vim~
File: a.vim

Notes:
* An old version of this plugin is required by |cpp_BuildTemplates.vim|.
  The latest version doesn't suit as I use its private functions...
* Otherwise, it is really nice and useful with C programming

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Georgi Slavchev's previewWord.vim~
File:       *previewWord.vim*
Requires:   |Triggers.vim| (supported)
Notes:      From a vim tip on sourceforge. ; Not required by anything

Option: 
    *g:previewIfHold* ([0]/1)
        Automatic search when the cursor hold its position ?

Mappings:
    <C-Space>       Looks for the declaration of the function name under
                    the cursor.
    <M-Space>       Toggles on/off the automatic search when the cursor
                    hold its position.
                    Defined only if |Triggers.vim| is installed.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                            *C_folding* *C++_folding*
C & C++ folding~
Files: fold/c-fold.vim fold/cpp-fold.vim
Notes:  
    * Initially developed by Johannes Zellner
    * To test and use them, drop them your ftplugin folders or look at
        cleaner solutions like the one used by Johannes Zellner.
    * Need to be tuned ; there are still some imperfections I haven't fixed
      yet. The major one beeing that the plugin may drastiscally slow down
      the loading of any C or C++ file.


------------------------------------------------------------------------------
                                                        *lh-cpp-first-steps*
First steps with lh-cpp-ftplugins~

The first steps with these ftplugins can be quite disorienting.
I expect you did read the |lh-cpp-features| section before trying to write your
first C or C++ files with the new ftplugins activated.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Step 1 : Opening a C or C++ file~
You do ~
>
    vim foo.h
or : >
    vim
    :e foo.h
<
Then you see ~
-> the new buffer filled with many things. 
Don't worry, it is a feature set by default: a template skeleton is inserted
in the new buffer. This is done thanks to |mu-template|.

If you don't like this feature ~
-> you have several options :
(*) you don't want template skeletons at all:
    then you can erase |mu-template.vim| and the {rtp}/after/templates/ folder
(*) you don't want template skeletons be inserted automatically:
    then add into your .vimrc: >
    let g:mt_IDontWantTemplatesAutomaticallyInserted = 1 
<   You will still have the possibility to _explicitly_ insert a template
    skeleton with: >
    :MuTemplate c                    " for the C skeleton
    :MuTemplate cpp                  " for the C++ skeleton
    :MuTemplate cpp/class            " for a heavily documented classes
    :MuTemplate cpp/singleton        " for Scott Meyers' singleton model.
    :MuTemplate cpp/stream-extractor " for op<< (beta, smart & slow)
    :MuTemplate cpp/stream-inserter  " for op>> (beta, smart & slow)
    :MuTemplate cpp/my-cpp           " for a specific C++ skeleton
(*) you don't want C++ skeleton (only) be inserted automatically, 
    [ie: you are OK for HTML and other skeletons] :
    Then rename the file {rtp}/after/template/template.cpp
    Don't change anything else than the extension of the file.
(*) you don't like the template skeletons I propose to you:
    easy ! Change them.
(*) you don't want to be in insert- or select-mode and at an odd place when
    opening a new file:
    This is |mu-template|'s fault. Deactivate this feature thanks to the
    option: |g:mt_jump_to_first_markers|.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Step 2 : Writing code and control statements~
You write ~
>
    if (foo)

Then you see ~
>
    if ((foo)«») {
        «»
    }«»

This is also a feature. Except you are not supposed to type "if (foo)", but
only "if foo".
You should by the way notice that "if", "else", "for", ... are expanded only
within normal code context: not within comments or strings contexts. Try for
instance: '// if foo' or '"if foo"'

If you don't like this feature ~
(*) What the hell are those '«»' characters that appear ?
    They are |markers|. They are supposed to help us reaching the next
    position in the file where we are supposed to add code.
    By default hit <M-Del> (/<M-S-Del>) to jump to the next (/previous) marker.
    If you don't want them, hit <M-F9> to toggle their activation state (only
    if |Triggers.vim| is installed), or set |b:usemarks| to 0 into your .vimrc.
    You should also be able to simply erase the file |bracketing.base.vim|
(*) You want some "\n" before the '(':
    Easy: explicitly set the option |g:c_nl_before_bracket| to 1.
(*) You want some "\n" between ')' and '{':
    Easy: explicitly set the option |g:c_nl_before_curlyB| to 1.
(*) You don't want the control statements to be expanded:
    Then, don't install |c_set.vim| and |cpp_set.vim|. Instead look and take
    the stuff you could be interested in, like for instance some vim-|options|.

If you only see~
>
    if (foo)

Then, it is probable that you haven't configured Vim to support ftplugins. To do
this, add one of the following lines into your .vimrc: >
    filetype plugin on
    filetype plugin indent on " is fine as well
Check |:filetype-plugin-on| for more info.


------------------------------------------------------------------------------
                                                        *lh-cpp_API*
lh-cpp API~
Here are the function made available to write your own ftplugins and
template-files.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                    *lh#cpp#dox#*

Doxygen related functions~
The following functions are parametrized, see |C++_doxygen-options|.

- Purely stylistic options~
 *lh#dox#comment_leading_char()*
    @see |(bg):[{ft}_]dox_CommentLeadingChar|
 *lh#dox#tag_leading_char()*
    @see |(bg):[{ft}_]dox_TagLeadingChar|
 *lh#dox#tag()*
    @returns |lh#dox#tag_leading_char()| + parameter 

- Semantics options, i.e. that return a tag and sometimes more~
 *lh#dox#semantics()*
    @returns "<p><b>Semantics</b><br>" 
 *lh#dox#ingroup()*
    @param name
    @see |(bg):[{ft}_]dox_ingroup|
 *lh#dox#brief()*
    @see |(bg):[{ft}_]dox_brief|
 *lh#dox#param()*
    @param p parameter description: text, or |Dictionary| {dir: in,out,inout; name}.
    @return lh#dox#tag("param") + p
 *lh#dox#author()*
    @param names (optional)
    @returns lh#dox#tag(|(bg):[{ft}_]dox_author_tag|) 
             + names or |(bg):[{ft}_]dox_author| if no names specified

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                    *lh#cpp#ftplugin#*
Convinience functions for ftplugin definitions only~
 *lh#cpp#ftplugin#OptionalClass()*
    Function that can be used to write |:command|s in |ftplugins| that tries
    to deduce the name of the current C++ class if none is provided.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                    *lh#cpp#style*
Functions dedicated to obtain information on the current style~
 *lh#cpp#style#get()*
    @param datakind
    @param pos
    @returns lh#option#get(datakind + pos, '')
 *lh#cpp#style#attribute2parameter_name()*
    @param attrb_name
    Applies the chosen naming style for parameters to a attribute name.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                            *lh#cpp#AnalysisLib_Function#*
Functions dedicated to the analysis of C/C++ functions~

*lh#cpp#AnalysisLib_Function#GetFunctionPrototype()*
*lh#cpp#AnalysisLib_Function#GetListOfParams()*
*lh#cpp#AnalysisLib_Function#AnalysePrototype()*
*lh#cpp#AnalysisLib_Function#HaveSameSignature()*
*lh#cpp#AnalysisLib_Function#BuildSignatureAsString()*
*lh#cpp#AnalysisLib_Function#IsSame()*
*lh#cpp#AnalysisLib_Function#LoadTags()*
*lh#cpp#AnalysisLib_Function#SearchUnmatched()*
*lh#cpp#AnalysisLib_Function#SearchAllDeclarations()*
*lh#cpp#AnalysisLib_Function#SignatureToSearchRegex2()*
*lh#cpp#AnalysisLib_Function#SignatureToSearchRegex()*
*lh#cpp#AnalysisLib_Function#TrimParametersNames()*

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                            *lh#cpp#AnalysisLib_Class#*
Functions dedicated to the analysis of C/C++ classes~
*lh#cpp#AnalysisLib_Class#SearchClassDefinition()*
*lh#cpp#AnalysisLib_Class#CurrentScope()*
*lh#cpp#AnalysisLib_Class#BaseClasses0()*
*lh#cpp#AnalysisLib_Class#GetClassTag()*
*lh#cpp#AnalysisLib_Class#FetchDirectParents()*
*lh#cpp#AnalysisLib_Class#Ancestors()*
*lh#cpp#AnalysisLib_Class#FetchDirectChildren()*
*lh#cpp#AnalysisLib_Class#used_namespaces()*
*lh#cpp#AnalysisLib_Class#attributes()*

------------------------------------------------------------------------------
                                                        *Files-from-lh-cpp*
Files~
$HOME/.vim/  (or $HOME/vimfiles/ ; cf. 'runtimepath')
+-> doc/
|   |   Don't forget to execute ':helptags $HOME/.vim/plugin/doc'
|   +-> |lh-cpp.txt|: this file
|
+-> ftplugin/
|   +-> c/
|   |   +-> |c_set.vim|                                required by |cpp_set.vim|
|   |   +-> |previewWord.vim|                          standalone
|   |   |    Stolen from vim tips
|   |   |    Can take advantage of |Triggers.vim|
|   |   +-> *c_stl.vim* : attempt to detect the current function and display its
|   |   |    signature within the status line.
|   |   |    It hangs for a while in some contexts => it has been desactivated.
|   |   |    Provided for VimL-hackers mainly.
|   |   +-> |c_compile.vim|
|   |   +-> *c_brackets.vim* : Customizes the |brackets-for-C| feature
|   |   +-> doc/
|   |       +-> |lh-cpp-readme.txt| : this file
|   |           Don't forget to execute ':helptags $HOME/.vim/ftplugin/c/doc'
|   +-> cpp/
|       +-> |cpp_set.vim|
|       +-> cpp_FindContextClass.vim                    required by IA
|       +-> |cpp_options-commands.vim|                  required by BT, IA & GFi
|       +-> |cpp_options.vim|                           required by BT, IA & GFi
|       +-> |cpp_BuildTemplates.vim|   [BT]             required by IA
|       +-> |cpp_InsertAccessors.vim|  [IA]
|       +-> |cpp_GotoFunctionImpl.vim| [GFi]
|     
+-> plugin/
|   +-> a.vim                                           required by IA & GFi
|   |     old version ; manipulates buffers and windows
|   +-> *homeLikeVC++.vim*                              standalone
|        toggles the position of the cursor when pressing <home>.
|        behaves like VC++ does.
|     
+-> macros/
|   +-> *options.vim*                                   req. by |c_compile.vim|
|       Defines a very common function: *LHOption()*
|
+-> after/template/
    +-> template.*      \ template files for |mu-template|
    +-> *               / 

Useful files not in the archive (but available on my web site):
$HOME/.vim/  (or $HOME/vimfiles/ ; cf. 'runtimepath')
+-> macros/
|   +-> menu-maps.vim
|       Help (ft)plugin writers to define coherent mappings and menus.
|       Supported by |c_compile.vim|
+-> plugin/
    +-> let-modeline.vim
        Extend modeline to VimL variables.
        Supported by |c_compile.vim|


------------------------------------------------------------------------------
Credits~

Many people have to be credited: 
* the Vim & VimL gurus ;
* the people I've stolen scripts and functions from: Stephen Riehm, Michael
  Sharpe, Georgi Slavchev, Johannes Zellner, Saul Lubkin ;
* the people that gave me many great ideas and even feedback: Gergely Kontra,
  Leif Wickland, Robert Kelly IV [I've also stolen scripts from them] ;
* Thomas Ribo for his feedback and features-requirements.
* and many more that I have probably forgotten.

TODO:~
- c_compile.vim / BTW


------------------------------------------------------------------------------
 © Luc Hermitte, 2001-2012 <http://code.google.com/p/lh-vim/wiki/lhCpp>, CC by SA 3.0
 VIM: let b:VS_language = 'american' 
 vim:ts=8:sw=4:tw=80:fo=tcq2:isk=!-~,^*,^\|,^\":ft=help:
