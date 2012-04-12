" ========================================================================
" $Id$
" File:		ftplugin/cpp/cpp_GotoFunctionImpl.vim                 {{{1
" Authors:	{{{2
" 		From an original mapping by Leif Wickland (VIM-TIP#335)
" 		See: http://vim.sourceforge.net/tip_view.php?tip_id=335 
" 		Firstly changed into a plugin (Mangled by) Robert KellyIV
" 		<Feral at FireTop.Com> 
" 		Rewritten by Luc Hermitte <hermitte at free.fr>, but features
" 		and fixes still mainly coming from Robert's ideas.
" 		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" }}}2
" Last Change:	$Date$ (05th May 2006)
" Version:	2.0.0
"------------------------------------------------------------------------
" Description:	
" 	Defines mappings and commands to jumps to the implementation of a
" 	function prototype. If the implementation cannot be found, then
" 	it provides a default one.
"
" Definitions: {{{2
" Commands:
" 	- :GOTOIMPL
" 	- :PASTEIMPL
" 	- :MOVETOIMPL
" Mappings:
" 	- ;GI
" 	- ;PI
" 	- ;MI
" }}}2
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" 	Requirements:
" 		vim7+
" 		{rtp}/autoload/lh/cpp/CodeAnalysisLib.vim
" History: {{{2
" 	Note: for simplicity reasons, this ftplugin may accept illegal C++
" 	code. If you find such a broken C++-rule, send me an email to see if I
" 	can fix it.
"
"    [Luc: 12th Apr 2012] v2.0.0: {{{3
"       (*) GPLv3 w/ extension
"       (*) facultative option: extension of the file where to put the
"           definition of the function.
"    [Luc: 06th Oct 2006] v0.8.6: {{{3
"    	(*) Code refactorized and moved to 
" 		{rtp}/autoload/lh/cpp/CodeAnalysisLib.vim
"    	    todo: search definition of operators
"    	    todo: support the ellipsis -> "..."
"    [Luc: 13th Sep 2006] v0.8.5: {{{3
"    	(*) :GOTOIMPL supports:
"    	    - parameters with default value being a function (vim 7+ only)
"    	    - C++ operators ; there is still a little issue with operator*
"    	    - exceptions specifications are unsupported
"    	    - pointer return types
"    [Luc: 16th May 2006] v0.8.4: {{{3
"	(*) :GOTOIMPL inserts code at the line _after_ the matching pattern
"    [Luc: 05th May 2006] v0.8.3: {{{3
"	(*) The alternate-file search has been patched for vim7.
"    [Luc: 18th Apr 2006] v0.8.2: {{{3
"	(*) "explicit" is handled like "static" and "virtual".
"	Todo:
"	(*) escape() the return type pointers (and reference as well probably)
"	    of functions.
"    [Luc: 27th Feb 2006] v0.8.1: {{{3
"	(*) New command (and related mappings) :MOVETOIMPL
"    [Luc: 22nd Nov 2005] v0.8.0: {{{3
"    	(*) Cpp_GetFunctionPrototype() can declarations from pure signatures
"	    only, or from definitions as well.  
"	(*) Cpp_GetListOfParams()
"
"    [Luc: 29th Apr 2005] v0.7.0: {{{3
"    	(*) Use g:alternateSearchPath (from a.vim) to check if the
"    	    implementation file (.cpp) exists in another directory from the list
"    	(*) New option: g:cpp_Split which tells where the implementation file
"    	    should be opened. Possible values are "h\%[orizontal]",
"    	    "v\%[ertical]" or anything which will be interpreted as "no-split".
"    	    By default if g:cpp_Split is not set, "vertical" is assumed.
"    	Todo: 
"    	(*) <bang> for PASTEIMPL and GOTOIMPL, same behavior than the one
"    	    of :put-!
"
"    [Luc: 17th oct 2002] v0.6.0: {{{3
"	(*) Supports destructors
"	(*) Supports namespaces: 
"	    + If the zone where the function implementation is going to be
"	      inserted is within a namespace, then the scope of the function
"	      will be corrected.
"	    + The |search-implementation| feature is able to differentiate
"	      functions according to the namespace they are within, and thus
"	      it is able jump to the right function. For instance:
"	        int NS::CL::FN(int i) {}	// is NS::CL::FN
"	        namespace NS0 {
"	            int NS::CL::FN(int i) {}	// is NS0::NS::CL:FN
"	        }
"    	(*) Checks whether the function is a pure virtual method and refuse to
"    	    define an implementation in such cases ...
"    	(*) When searching for the implementation of a function within the
"    	    .cpp file, comments before the signature will be ignored ; i.e.
"    	    the cursor will move to the return-type. The difference is
"    	    noticeable on virtual or static functions.
"    	(*) s/GIMPL/GOTOIMPL
"	Todo:
"	(*) Pb (now hanging) when searching/building/checking when GOTOIMPL is
"	    invoked on a non function
"	(*) Pb when GOTOIMPL invoked on a function call within an
"	    implementation -- searching/checking for {} may do the trick
"	(*) Skip comments with searchpair()
"
"    [Luc: 15th oct 2002] v0.5.0: {{{3
"	(*) The management of cpp_options.vim has been moved to another file. 
"	(*) Comments are completely ignored when searching for the
"    	    implementation of a function. Actually, the match is done
"    	    according to the list of types only -- even parameter names will
"    	    be ignored.
"    	    Hence: the programmer can change the name of the parameters and/or
"    	    add comments wherever she want within the function's header.
"    	    Parameters-types Supported: 
"    	    - simple types (int, unsigned short int, signed double, etc)
"    	    - pointers, references and const modifiers usable
"    	    - arrays "T p[][xx]"
"    	    - arrays of pointers and pointers of arrays: 
"    	    	"T (*p)[][N]", "T* p[][N]"
"    	    - complex types with scopes : "T1::T2::T3"
"	(*) Inlines functions (within the class def) (ie not prototypes) will
"    	    be ignored
"	(*) Enhancements and little bugs corrections regarding default
"	    parameters 
"	(*) We can specify where we want the default implementation code to be
"	    written ; cf cpp_options.vim and g:cpp_FunctionPosition.
"    	Todo:
"    	(*) Check about declared exceptions : 'throws'
"    	(*) Possibility to extend the list of simple types (__int64, long
"    	    long, UINT, etc) on user request/conf.
"    	(*) Support very complex types : function types, template types.
"    	    Must we consider that p for "T p[10]", "T p[]" and "T p[N]" have
"    	    the same type ? 
"    	    Don't differentiate:
"    	      "T * p$" and "T (*p)$" ; "const T" and "T const"
"
"    [Luc: 08th oct 2002] v0.4.0: {{{3
"    	(*) Accepts comments within the signature and trim them.
"    	(*) If something is written between the ')' and the ';', even on
"    	    new line, it will be understood as part of the prototype
"    	    (typically 'const' and '=0').
"    	    But: We can not put the cursor on this particular line and then
"    	    invoke the command ; the last line accepted is the one of the
"    	    closing parenthesis.
"
"    [Luc: 08th oct 2002] v0.3.0: {{{3
"    	(*) No more parameters don't require anymore to be on the same line
"    	    But, the return type and the possible const modifier on the
"    	    function must.
"    	(*) No more registers, 
"    	(*) Works with member and non-member functions.
"    	(*) Requires some other files of mine.
"    	    => Can handle nested class.
"    	(*) If an implementation already exists for the function, we go to
"    	    this implementation, otherwise we add it at once.
"    	(*) The command accept optional arguments
"    	(*) Add two default mappings for normal and insert modes, can be
"    	    easily remapped to anything we want.
"    	(*) Divergence in the versionning from now
"    	Todo:
"    	(*) Enable multi-lines prototypes
"    	    Status: Half implemented in 0.4
"    	(*) Memorize the current cursor position ? -> option
"    	(*) Use tags to achieve a more accurate search
"    	(*) Check whether the function is a pure virtual method and refuse to
"    	    define an implementation ...
"    	    Status: done in 0.6
"
"    [Feral:274/02@20:42] v0.2.0: {{{3
"	Improvements: from Leif's Tip (#335): 
"	(*) can handle any number of default params (as long as they are all 
"	    on the same line!) 
"	    Status: 2/3 fixed with ver 0.4
"	(*) Options on how to format default params, virtual and static. 
"	         (see below) TextLink:||@|Prototype:| 
"	(*) placed commands into a function (at least I think it's an
"	    improvement ;) ) 
"	(*) Improved clarity of the code, at least I hope. 
"	(*) Preserves registers/marks. (rather does not use marks), Should not
"	    dirty anything. 
"	(*) All normal operations do not use mappings i.e. :normal! 
"	   (I have Y mapped to y$ so Leif's mappings could fail.) 
" 
"	Limitations: 
"	(*) fails on multi line declarations. All params must be on the same 
"	    line. 
"	    Status: 2/3 fixed with ver 0.4
"	(*) fails for non member functions. (though not horribly, just have to
"	    remove the IncorectClass:: text... 
"	    Status: fixed with 0.3.
"
"    [Leif:] v0.1 {{{3
"	 Leif's original VIM-Tip #335 
"
" Requirements: {{{2
" 		VIM 6.0, 
" 		cpp_FindContextClass.vim, cpp_options-commands.vim, 
" 		a.vim
" }}}1
"#############################################################################
" Buffer Relative stuff {{{1
if exists("b:loaded_ftplug_cpp_GotoFunctionImpl") 
      \ && !exists('g:force_load_cpp_GotoFunctionImpl')
    finish 
endif 
let b:loaded_ftplug_cpp_GotoFunctionImpl = 200
let s:cpo_save=&cpo
set cpo&vim

" ==========================================================================

" Commands: {{{2
" Possible Arguments: 
"  'ShowVirtualon', 'ShowVirtualoff', 'ShowVirtual0', 'ShowVirtual1',
"  'ShowStaticon', '..off', '..0' or '..1'
"  'ShowExplicitcon', '..off', '..0' or '..1'
"  'ShowDefaultParamson', '..off', '..0', '..1',  or '..2'
"  {extension} -> cpp,txx,cxx, etc when there can be a choice where to have the
"  function definition

command! -buffer -nargs=* GOTOIMPL call lh#cpp#GotoFunctionImpl#GrabFromHeaderPasteInSource(<f-args>)

" In order to insert the default implementation when the user want it (with
" the option g:cpp_FunctionPosition set to 3 ; Robert's approach) or after a
" positioning error (ie: if a searched pattern is not found, them :PASTEIMPL
" will be usable).
command! -buffer -nargs=0 PASTEIMPL call lh#cpp#GotoFunctionImpl#InsertCodeAtLine()

" Like GOTOIMPL, but instead move an inlined function to a separate .cpp file
command! -buffer -nargs=* MOVETOIMPL call lh#cpp#GotoFunctionImpl#MoveImpl(<f-args>)

" Mappings: {{{2
" normal mode mapping ; still possible to set parameters
nnoremap <buffer> <Plug>GotoImpl	:GOTOIMPL<SPACE>
nnoremap <buffer> <Plug>PasteImpl	:PASTEIMPL<CR>
nnoremap <buffer> <Plug>MoveToImpl	:MOVETOIMPL<CR>

if !hasmapto('<Plug>GotoImpl', 'n')
  nmap <buffer> ;GI <Plug>GotoImpl
  " <LeftMouse> is used to position the cursor first
  nmap <buffer> <M-LeftMouse>  <LeftMouse><Plug>GotoImpl<CR>
endif
if !hasmapto('<Plug>PasteImpl', 'n')
  nmap <buffer> ;PI <Plug>PasteImpl
  nmap <buffer> <M-RightMouse> <LeftMouse><Plug>PasteImpl
endif
if !hasmapto('<Plug>MoveToImpl', 'n')
  nmap <buffer> ;MI <Plug>MoveToImpl
  " <LeftMouse> is used to position the cursor first
  " nmap <buffer> <M-LeftMouse>  <LeftMouse><Plug>MoveToImpl<CR>
endif
" insert mode mapping ; use global parameters
inoremap <buffer> <Plug>GotoImpl	<C-O>:GOTOIMPL<CR>
inoremap <buffer> <Plug>PasteImpl	<C-O>:PASTEIMPL<CR>
if !hasmapto('<Plug>GotoImpl', 'i')
  imap <buffer> <C-X>GI <Plug>GotoImpl
  imap <buffer> <M-LeftMouse>  <LeftMouse><Plug>GotoImpl
endif
if !hasmapto('<Plug>PasteImpl', 'i')
  imap <buffer> <C-X>PI <Plug>PasteImpl
  imap <buffer> <M-RightMouse> <LeftMouse><Plug>PasteImpl
endif
if !hasmapto('<Plug>MoveToImpl', 'i')
  imap <buffer> <C-X>MI <Plug>MoveToImpl
endif

" }}}1
"=============================================================================
" Global definitions {{{1
if exists("g:loaded_cpp_GotoFunctionImpl") 
      \ && !exists('g:force_load_cpp_GotoFunctionImpl')
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_cpp_GotoFunctionImpl = 1
"------------------------------------------------------------------------
" Menus {{{2
"
let s:menu_prio = lh#option#get('cpp_menu_priority', '50', 'g')
let s:menu_name = lh#option#get('cpp_menu_name',     '&C++', 'g')


let s:FunctionPositionMenu = {
      \ "variable": "cpp_FunctionPosition",
      \ "idx_crt_value": 0,
      \ "texts": [ 'end-of-file', 'pattern', 'function', 'other' ],
      \ "values": [ 1, 2, 3, 4 ],
      \ "menu": {
      \     "priority": s:menu_prio.'.90.10',
      \     "name": s:menu_name.'.&Options.&New-function-position'}
      \}

call lh#menu#def_toggle_item(s:FunctionPositionMenu)
"------------------------------------------------------------------------
" }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
" }}}
"=============================================================================
" Documentation {{{1
"***************************************************************** 
" given: 
"    virtual void Test_Member_Function_B3(int _iSomeNum2 = 5, char * _cpStr = "Yea buddy!"); 

" Prototype: 
"GrabFromHeaderPasteInSource(VirtualFlag, StaticFlag, DefaultParamsFlag) 

" VirtualFlag: 
" 1:    if you want virtual commented in the implementation: 
"    /*virtual*/ void Test_Member_Function_B3(int _iSomeNum2 = 5, char * _cpStr = "Yea buddy!"); 
" else:    remove virtual and any spaces/tabs after it. 
"    void Test_Member_Function_B3(int _iSomeNum2 = 5, char * _cpStr = "Yea buddy!"); 

" StaticFlag: 
" 1:    if you want static commented in the implementation: 
"    Same as virtual, save deal with static 
" else:    remove static and any spaces/tabs after it. 
"    Same as virtual, save deal with static 

" ExplicitFlag: 
" 1:    if you want explicit commented in the implementation: 
"    Same as virtual, save deal with explicit 
" else:    remove explicit and any spaces/tabs after it. 
"    Same as virtual, save deal with explicit 

" DefaultParamsFlag: 
" 1:    If you want to remove default param reminders, i.e. 
"    Test_Member_Function_B3(int _iSomeNum2, char * _cpStr); 
" 2:    If you want to comment default param assignments, i.e. 
"    Test_Member_Function_B3(int _iSomeNum2/*= 5*/, char * _cpStr/*= "Yea buddy!"*/); 
" 3:    Like 2 but, If you do not want the = in the comment, i.e. 
"    Test_Member_Function_B3(int _iSomeNum2/*5*/, char * _cpStr/*"Yea buddy!"*/); 
" 
" Examples: 
" smallest implementation: 
"    void Test_Member_Function_B3(int _iSomeNum2, char * _cpStr); 
":command! -nargs=0 GHPH call <SID>GrabFromHeaderPasteInSource(0,0,1) 
"    Verbose...: 
"    /*virtual*/ void Test_Member_Function_B3(int _iSomeNum2/*5*/, char * _cpStr/*"Yea buddy!"*/); 
":command! -nargs=0 GHPH call <SID>GrabFromHeaderPasteInSource(1,1,3) 
"    What I like: 
"    void Test_Member_Function_B3(int _iSomeNum2/*5*/, char * _cpStr/*"Yea buddy!"*/); 
" }}}1
"=============================================================================
" vim60:fdm=marker 
