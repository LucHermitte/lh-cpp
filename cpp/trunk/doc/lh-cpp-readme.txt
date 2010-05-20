*lh-cpp-readme.txt*     C & C++ ftplugins short presentation
                        For Vim version 6.x.    Last change: 02nd May 2005


                               By Luc Hermitte
                               <hermitte {at} free {dot} fr>


------------------------------------------------------------------------------
This a very short guide to the archive lh-cpp.tar.gz

Contents~
|lh-cpp-features|       The features proposed by the ftplugins
|lh-cpp-first-steps|    Your first steps with these ftplugins
|Files-from-lh-cpp|     The files that compose the archive
|add-local-help|        Instructions on installing this file (:helptags %:h)


------------------------------------------------------------------------------
                                                        *lh-cpp-features*
Features~
|brackets-for-C|                Bracketing system
|C_control-statements|          Control statements for C editing (for, if, etc)
|C_settings|                    Various settings
|C++_control-statements|        Control statements for C++ editing (try, ...)
|C++_accessors|                 C++ accessors & some templates skeletons
|C++_jump_implementation|       Jumping to functions-implementation
|C++_options|                   Options for different features (i.e. ftplugins)

|mu-template.txt|               Gergely Kontra's mu-template
|previewWord.vim|               Georgi Slavchev's previewWord.vim
|C_folding| |C++_folding|       C & C++ folding
|search-in-runtimepath|         Searching in various directories lists

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                        *brackets-for-C*
    Bracketing system~
    Files:      |bracketing.base.vim| & |common_brackets.vim|
    Requires:   |misc_map.vim| (needed); |Triggers.vim| (supported)
    Help:       <http://hermitte.free.fr/vim/settings.php>
    
    Options:    
        |b:usemarks|                                    (0/[1]) 
            to enable the insertion of |markers|.
        |g:marker_prefers_select|                       (0/[1]) 
            select or echo the text within marker.
        |g:marker_select_empty_marks|                   (0/[1]). 
            select or delete markers on !jump!
        and many more that are pointless here.
    
    Mappings defined in this particular configuration:
        |!mark!|   inserts a |marker| -- default: «»
        |!jump!|   jumps to the next marker
        |!jumpB!|  jumps to the previous marker
        <M-Ins>   shortcut to !mark!    ; can be redefined
        <M-Del>   shortcut to !jump!    ; can be redefined
        <M-S-Del> shortcut to !jumpB!   ; can be redefined
        {       {\n\n}  + |markers| (if |b:usemarks|==1) and cursor positioned
        [       []      + |markers| (if |b:usemarks|==1) and cursor positioned
        "       ""      + |markers| (if |b:usemarks|==1) and cursor positioned
        '       ''      + |markers| (if |b:usemarks|==1) and cursor positioned
        <F9>    toggles the 4 previous mappings   ; requires |Triggers.vim|
        <M-F9>  toggles the value of |b:usemarks| ; requires |Triggers.vim|

        <       expands into <!cursor!>!mark! if the opening angle-bracket
            immediatelly follows ``#include'', a C++ cast, ``template'' or
            ``typename''. Otherwise, it is not expanded.
    
     n&vmap: <localleader>{ 
           Insert a pair of curly brackets around the current line (/visual
           selection). It is done is respect of |b:usemarks|.

    + some mappings from auxtex.vim to manipulate brackets
        <M-b>x <M-b><Delete> : delete a pair of brackets
        <M-b>(  replaces the current pair of brackets with parenthesis
        <M-b>[  replaces the current pair of brackets with square brackets
        <M-b>{  replaces the current pair of brackets with curly brackets
        <M-b><  replaces the current pair of brackets with angle brackets
        <M-b>\  toggles the backslash on a pair of brackets
    
    NB: the brackets mappings only insert the markers when |b:usemarks| == 1,
        and they are buffer relative.
        
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                        *C_control-statements*
    C Control statements~
    File:       |c_set.vim|
    Requires:   |misc_map.vim| (needed); |brackets-for-C| (supported)
    Help:         <http://hermitte.free.fr/vim/settings.php>
                & <http://hermitte.free.fr/vim/c.php>
    
    Mappings and abbreviations defined: [always buffer-relative]
     abbr: if    if {\n}        + |markers| (if |b:usemarks|==1)   *C_if*
                                + cursor positioned
     abbr: elif   else if {\n}      + ...                          *C_elif*
     abbr: else   if {\n}           + ...                          *C_else*
     abbr: while  while {\n}        + ...                          *C_while*
     abbr: for    for(;;) {\n}      + ...                          *C_for*
     abbr: switch switch {\n}       + ...                          *C_switch*
     abbr: main   int main() \n{\n} + ...                          *C_main*
 
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
                                                        *C_settings*
    Various settings from c_set.vim~
    File:       *c_set.vim*

    Vim-options~
        'formatoptions' is set `to' `croql'
        'cindent'       is set.
        'cinoptions'    is set to ``g0,t0'' 
                                (``g0,t0,h1s'' for C++ with |cpp_set.vim|).
        'define'        is set to recognize defines and constants.
        'comments'      is set to ``sr:/*,mb:*,exl:*/,://''
        'isk'           is completed with ``#'', thus ``#if'' is considered to
                        be a keyword.
        'ch'            is set to 2.
        'showmode'      is unset.
        'dictionary'    is completed with ``{rtp}/ftplugin/c/word.list''.
        'complete'      is completed with ``k''
        'localleader'   is set to ``,'', unless it is already defined.

    Abbreviations~
        #n      expands into "#include", in respect of the context.
        #d      expands into "#define", in respect of the context.
        #i      expands into "#ifdef", in respect of the context.
        #e      expands into "#endif", in respect of the context.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                        *C++_control-statements*
    C++ Control statements~
    Files:      *cpp_set.vim*
    Requires:   |C_control-statements|
    Help:         <http://hermitte.free.fr/vim/general.php>
                & <http://hermitte.free.fr/vim/c.php>

    Mappings and abbreviations defined: [always buffer-relative]
     abbr: namespace namespace {\n} + markers and cursor pos.   *C_namespace*
           expanded only in it does not follow ``using''
     abbr: try   try{\n}catch(){\n} + markers and cursor pos.   *C_try*
     abbr: catch catch(){\n}    + markers and cursor positioned *C_catch*
     abbr: pub   public:                                        *C_pub*
     abbr: pro   protected:                                     *C_pro*
     abbr: pri   private:                                       *C_pri*
     abbr: tpl   template<>                                     *C_tpl*
     abbr: virt  virtual                                        *C_virt*
     imap: <M-s>        std::                                   *Ci_META-s*
     imap: <M-b>        boost::                                 *Ci_META-b*
     imap: <M-l>        luc_lib::                               *Ci_META-l*
                (very personal mapping you won't need)
 
     imap: <c-x>be                                              *Ci_CTRL-X_be*
     imap: <c-x>rbe                                             *Ci_CTRL-X_rbe*
            Duplicates the text within parenthesis, add a comma between the two
            occurrences, and append '.begin()' and '.end()' (or 'rbegin()',
            'rend()') to each.

     imap: /*<space>    /** */!mark!                            *C++_comments*
     imap: /**          /**\n*/!mark!

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

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                            *C++_accessors* *getter* *setter*
    C++ accessors & some templates~
    Files:      *cpp_BuildTemplates.vim* , cpp_FindContextClass &
                *cpp_InsertAccessors.vim*
    Help:       <http://hermitte.free.fr/vim/c.php>
    Requires:   |cpp_options-commands.vim| (needed), |a.vim| (optional)
    Options:    |cpp_options.vim|

                            *:HEADER* *:CLASS* *:BLINES* *:GROUP* *:MGROUP*
                            *:ADDATTRIBUTE* *:REACHINLINE*
    Commands:           Mappings to them:
        :HEADER {name}      ;HE         Header file template
        :CLASS  {name}      ;CL         Class declaration template
        :BLINES {name}      ;BL         Inserts rulers
        :GROUP  {name}      ;GR         Inserts a Doc++ group
        :MGROUP {name}      ;MGR        Inserts a Doc++ group + a ruler
        :ADDATTRIBUTE       ;AA         (do it, cursor on the "private" line)
        :REACHINLINE {name} ;RI         Reaches the place where inlines are
                                        defined
    Options:
        *g:setPrefix* *g:getPrefix* *g:refPrefix* accessors names
        *g:dataPrefix* *g:dataSuffix* member variables names
        *g:accessorCap* decides the capitalization ...
            ... of the first letter of the attribute within accessor-names
            -1  -> always lowercase ; Foo => get_foo(), foo => get_foo()
            [0] -> no change        ; Foo => get_Foo(), foo => get_foo()
             1  -> always uppercase ; Foo => get_Foo(), foo => get_Foo()

        *g:accessor_comment_get* *g:accessor_comment_proxy_get*
        *g:accessor_comment_set* *g:accessor_comment_proxy_set*
        *g:accessor_comment_ref* *g:accessor_comment_proxy_ref*
            => strings to customize the comments
            "%a" will be substituted by the name of the attribute.

        *g:implPlace* where accessor-definitions occur 
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
        * The ADDATTRIBUTE command (that inserts an attribute and accessors
          and mutators -- getters and setters) requires that some formating is
          respected -- you will certainly have to adapt it.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
                                                    *C++_jump_implementation*
    Jumping to functions-implementation~
    Files:      cpp_FindContextClass & *cpp_GotoFunctionImpl.vim*
    Help:       <http://hermitte.free.fr/vim/c.php>
    Requires:   |cpp_options-commands.vim| (needed), |a.vim| (optional)
    Options:    |cpp_options.vim|
    Inspiration:Leif Wickland's VIM TIP #135, and Robert Kelly IV for many
                features.

    Commands:               Mappings to them:
        :GOTOIMPL {options}     ;GI                             *:GOTOIMPL*
                            <C-X>GI     [Insert mode default mapping]
                            <M-LeftMouse>
            Go to the implementation of the current function, if the
            implementation does not exist yet, a default one will be provided.
            To change the keybindings:  <Plug>GotoImpl

        :PASTEIMPL              ;PI                             *:PASTEIMPL*
                            <C-X>PI     [Insert mode default mapping]
                            <M-RightMouse>
            Insert the function-implementation on the next line
            To change the keybindings:  <Plug>PasteImpl

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
        *g:cpp_ShowVirtual*             (0/1)
            When true, if the function is virtual, then the comment
            /*virtual*/ will be added at the beginning of the proposed
            implementation.
        *g:cpp_ShowStatic*              (0/1)
            When true, if the function is static, then the comment /*static,*/
            will be added at the beginning of the proposed implementation.
        *g:cpp_ShowDefaultParams*       (0/1/2/3)
            Determines if a comment will be added for every parameter having a
            default value -- according to the function-signature.
                0 -> No reminder
                1 -> /* = {theDefaultValue} */
                2 -> /*={theDefaultValue}*/
                3 -> /*{theDefaultValue}*/
        *g:cpp_FunctionPosition* & *g:cpp_FunctionPosArg*
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
                                                                *C++_options*
    C++ options~
    Files:      *cpp_options-commands.vim* *cpp_options.vim*
    Help:       <http://hermitte.free.fr/vim/c.php>
    Options:    |cpp_options.vim|

    Command:    
        *:CheckOptions* takes care of loading the options used by the various
            C++-ftplugins.
            These options must be defined in a file named |cpp_options.vim|.
            By default, we use the version stored into the directory:
            {rtp}/ftplugin/cpp/. If a file of this same name is present into the
            current directory, then it will get sourced instead.

    Notes: 
        * At this time, this feature is only used to define ("quality")
          presentation preferences. Every project can have its own settings.
        * There is no inheritance between the different versions of
          |cpp_options.vim|: i.e. an option defined into {rtp}/ftplugin/cpp/ is
          not used even if it is not overridden into the current directory.
        * There is no inheritance between the different directories: i.e. the
          options-file present in the parent directory of the current
          directory will be ignored. At this time, to share options between
          the different directories of the projet, you will have to maintain
          several occurrences of |cpp_options.vim| or use another plugin like
          |project.txt|.
        * The options are supposed to be global options.
        * If an option is changed from Vim command-line, it may not be kept as
          the definitions from |cpp_options.vim| are reloaded every-time we
          change directory.

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

The first steps with these ftplugins can be quite desorienting.
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
    :MuTemplate cpp/class            " for a heavilly documented classes
    :MuTemplate cpp/singleton        " for Scott Meyers' singleton model.
    :MuTemplate cpp/stream-extractor " for op<< (beta, smart & slow)
    :MuTemplate cpp/stream-inserter  " for op>> (beta, smart & slow)
    :MuTemplate cpp/my-cpp           " for a specfic C++ skeleton
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
                                                        *Files-from-lh-cpp*
Files~
$HOME/.vim/  (or $HOME/vimfiles/ ; cf. 'runtimepath')
+-> doc/
|   |   Don't forget to execute ':helptags $HOME/.vim/plugin/doc'
|   +-> |lh-map-tools.txt| : more precise help regarding the |bracketing| system
|   +-> |searchInRuntime.txt| : documentation for |searchInRuntime.vim|
|   +-> |mu-template.txt|     : documentation for |mu-template|
|   +-> |system_utils.txt|    : documentation for |system_utils.vim|
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
|   +-> |bracketing.base.vim|                           supported
|   |   | defines markers to insert after brackets
|   +---+-> |common_brackets.vim|                       supported
|   |        defines brackets mappings
|   |
|   +-> |Triggers.vim|                                  optional
|   |   | supported by |common_brackets.vim| to enable/disable |markers|
|   +---+-> *fileuptodate.vim*                          required by Triggers
|   |   |   checks whether a file is more recent than another
|   +---+-> |system_utils.vim|                          required by Triggers
|   |   |   ensures a directory exists
|   |   |   changes a path name to respect the 'shell' settings
|   +-> a.vim                                           required by IA & GFi
|   |     old version ; manipulates buffers and windows
|   |
|   +-> |misc_map.vim|
|   |    required by |c_set.vim|, |cpp_set.vim| and |common_brackets.vim|
|   |    defines all the functions used to implement the context aware
|   |    mappings from |c_set.vim| and |cpp_set.vim|
|   +-> |searchInRuntime.vim|                           needed by |mu-template|
|   |    extends |:runtime| to other commands
|   |    used by |mu-template| to correctly search in 'runtimepath'
|   +-> *word_tools.vim*                                needed by |mu-template|
|   |    defines more accurate alternatives to |expand()| applied on "<cword>"
|   +-> |ui-functions.vim|                              supp. by |mu-template|
|   |    defines functions that will ease the definition of template-files.
|   |    Required by the template file: template.vim
|   |    Required by |c_compile.vim|
|   +-> *homeLikeVC++.vim*                              standalone
|        toggles the position of the cursor when pressing <home>.
|        behaves like VC++ does.
|     
+-> macros/
|   +-> *options.vim*                                   req. by |c_compile.vim|
|       Defines a very common function: *LHOption()*
|
+-> after/plugin/
|   +-> |mu-template.vim|(v0.31)                        supported by IA
|        inserts template files
|        IA is compatible with this version: i.e. no undesired behaviors
|        Not required by anything, but supported by the other scripts.
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
- move to {rtp}/doc/
- Surround() ne respecte pas c_nl_before_xxx


------------------------------------------------------------------------------
 © Luc Hermitte, 2001-2005 <http://hermitte.free.fr/vim/c.php>
 VIM: let b:VS_language = 'american' 
 vim:ts=8:sw=4:tw=80:fo=tcq2:isk=!-~,^*,^\|,^\":ft=help:
