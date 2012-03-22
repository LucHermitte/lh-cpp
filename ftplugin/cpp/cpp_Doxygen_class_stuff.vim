"=============================================================================
" $Id$
" File:         ftplugin/cpp/cpp_Doxygen_class_stuff.vim                {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	20th Apr 2006
" Last Update:	$Date$ (17th Dec 2007)
"------------------------------------------------------------------------
" Description:	
" 	Provides VimL functions used by the C++ µ-template-file for "class"es 
" 	This C++ ftplugin is for internal use only!
"
" NB:
" 	The template-file proposes to choose a semantics for the class betwwen:
" 	- Value semantics (stack-based, copyable)
" 	- Stack based semantics, but non-copyable.
" 	- Entity semantics (reference semantics, non-copyable)
" 	- Entity semantics (reference semantics, clonable)
" 	The default constructors, operators and destructors will be provided
" 	accordingly.
" 
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" Dependencies:	Mu-template
" Todo:
" 	- Check for classes (hint: taglist()) we can inherit from, and propose
" 	to inherit.
" }}}1
"=============================================================================


"=============================================================================
" Avoid buffer reinclusion                                 {{{1
let s:cpo_save=&cpo
set cpo&vim
if exists('b:loaded_ftplug_cpp_Doxygen_class_stuff')
       \ && !exists('g:force_reload_cpp_Doxygen_class_stuff')
  let &cpo=s:cpo_save
  finish
endif
let b:loaded_ftplug_cpp_Doxygen_class_stuff = 1
 
" }}}1
"------------------------------------------------------------------------
" Commands and mappings                                    {{{1
" «Buffer relative definitions»
 
" Commands and mappings }}}1
"=============================================================================
" Avoid global reinclusion                                 {{{1
if exists("g:loaded_cpp_Doxygen_class_stuff") 
      \ && !exists('g:force_reload_cpp_Doxygen_class_stuff')
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_cpp_Doxygen_class_stuff = 1
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Functions                                                {{{1

" Internal functions                             {{{2

" Function: s:Lead()                                       {{{3
function! s:Lead()
  return ' '.lh#dox#comment_leading_char().' '
endfunction

"
" Function: s:CopyConstructor   ({clsname} [, {text} ])    {{{3 
" @param[in] {clsname}	Is the name of the englobbing class
" @param[in] {text}	@brief text in case the copy-ctr is not public
function! s:CopyConstructor(clsname, ...)
  let lead = s:Lead()
  let type = (a:0 == 0)
	\ ? ''
	\ : (a:1.' ')
  let text = "/**\n"
	\ . lead.type."Copy Constructor.\n"
	\ . " ".lh#dox#comment_leading_char()."\n"
  if a:0 == 0
    let text = text
	  \ . lead.lh#dox#tag("param[in]")." rhs_ source data to be copied.\n"
	  \ . lead.Marker_Txt(lh#dox#tag('throw '))."\n"
  else
    let text = text
	  \ . lead.'The semantics of \c '.a:clsname." requires for\n"
	  \ . lead."the copy constructor to not be publicly accessible.\n"
  endif
  let text = text
	\ . " */"
	\ . "\n"
  let text = text .
	\ a:clsname . '('.a:clsname.' const& rhs_);'
	\ . "\n"
  return text
endfunction

" Function: s:AssignmentOperator({clsname} [, {text} ])    {{{3 
" @param[in] {clsname}	Is the name of the englobbing class
" @param[in] {text}	@brief text in case the copy-ctr is not public
function! s:AssignmentOperator(clsname, ...)
  let lead = s:Lead()
  let type = (a:0 == 0)
	\ ? ''
	\ : (a:1.' ')
  let text = "/**\n"
	\ . lead.type."Assignment Operator.\n"
	\ . " *\n"
  if a:0 == 0
    let text = text
	  \ . lead.lh#dox#tag("param[in]")." rhs_ source data to be copied.\n"
	  \ . lead.lh#dox#tag("return")." \\c this\n"
	  \ . lead.Marker_Txt(lh#dox#tag('throw '))."\n"
  else
    let text = text
	  \ . lead.'The semantics of \c '.a:clsname." requires for\n"
	  \ . lead."the assignment operator to not be defined.\n"
  endif
  let text = text
	\ . " */"
	\ . "\n"
  let text = text .
	\ a:clsname . ' & operator=('.a:clsname.' const& rhs_);'
	\ . "\n"
  return text
endfunction

" Public functions                               {{{2
"
" Function s:CppDox_ClassWizard({clsname}) {{{3
" @param[in] {clsname}	Name of the class for which charateristics are asked.
function! CppDox_ClassWizard(clsname)
  let lead = s:Lead()
  " todo: present the list of classes we can inherit
  " Then, for each class, we select the type of inheritance:
  " - is-a => default non copyable/clonable
  " - implemented-in-term-of
  " - not tied
  "
  " todo2: we can select the type of coupling (composition, 1, 0..1, 0..*, ...)

  let semantics = confirm("What is the semantics of ".a:clsname."?",
	\ "&Value semantics (stack-based, copyable, comparable(?))\n"
	\."&Stack based semantics (non-copyable)\n"
	\."&Entity semantics (reference semantics, non-copyable)\n"
	\."Entity semantics (reference semantics, &clonable)",
	\ 2)
  if semantics == 0 " default choice => non copyable 
    let semantics = 2
  endif


  let g:CppDox_constructors      = a:clsname.'();' 
  let g:CppDox_do_copy           = 0
  let g:CppDox_isVirtualDest     = ''
  let g:CppDox_inherits      	 = ''
  let g:CppDox_protected_members = ''
  let g:CppDox_forbidden_members = ''
  let g:CppDox_semantics 	 = ''

  if     semantics == 1 " value semantics
    " => inherits from nothing 
    "    todo: idiom envelop/letter
    let g:CppDox_isVirtualDest = ''
    let g:CppDox_do_copy = 1
    let g:CppDox_constructors = g:CppDox_constructors . "\n" .
	  \ s:CopyConstructor(a:clsname)
    let g:CppDox_constructors = g:CppDox_constructors . "\n" .
	  \ s:AssignmentOperator(a:clsname)
    let g:CppDox_inherits  = ''
    let g:CppDox_semantics =
	  \ lead."-  Full value semantics (stack-based, copyable".Marker_Txt(", comparable").")\n"

  elseif semantics == 2 " stack-based semantics, non-copyable
    let g:CppDox_isVirtualDest = ''
    let g:CppDox_inherits = ': public boost::noncopyable'
    let g:CppDox_semantics =
	  \ lead."-  Stack-based semantics\n"
	  \.lead."-  Non-copyable"

  elseif semantics == 3 " entity semantics, non-copyable
    let g:CppDox_isVirtualDest = 'virtual '
    let g:CppDox_inherits = ': public boost::noncopyable'.
	  \ Marker_Txt(', other ancestors')
    let g:CppDox_semantics =
	  \ lead."-  Entity semantics (=> reference semantics)\n"
	  \.lead."-  Non-copyable"

  elseif semantics == 4 " entity semantics, clonable
    let g:CppDox_isVirtualDest = 'virtual '
    let g:CppDox_inherits = ': <ancestors+>'
    let g:CppDox_protected_members = 
	  \ s:CopyConstructor(a:clsname, "Access limited")
          \."\n"
    let g:CppDox_forbidden_members = 
	  \ s:AssignmentOperator(a:clsname, "Disabled")
    let g:CppDox_semantics =
	  \ lead."-  Entity semantics (=> reference semantics)\n"
	  \.lead."-  Clonable"
  endif

endfunction

" Function s:CppDox_SingletonWizard({clsname}) {{{3
" @param[in] {clsname}	Name of the class for which charateristics are asked.
function! CppDox_SingletonWizard(clsname)
  let lead = s:Lead()
  " todo: 
  " - CRTP approach
  "
  " todo2: we can select the type of coupling (composition, 1, 0..1, 0..*, ...)

  let type = confirm("Of what type of singleton ".a:clsname." should be?",
	\ "&Meyers' (local-static, MT-safe, default ctr)\n"
	\."&Explicit Initialisation (MT-safe)",
	\ 2)
  if type == 0 " default choice => non copyable 
    let type = 2
  endif


  let g:CppDox_constructors       = a:clsname.'();' 
  let g:CppDox_inherits           = ''
  let g:CppDox_semantics          = ''
  let g:CppDox_instance           = ''
  let g:CppDox_forbidden_members  = ''
  let g:CppDox_private_members    = Marker_Txt('attributes')
  let g:CppDox_stuff_for_cpp_file = ''

  if     type == 1 " Scott Meyers'
    let g:CppDox_inherits           = ": private boost::noncopyable"
    let g:CppDox_semantics          =
          \ lead."-  Implicitly initialized with a default constructor\n"
	  \.lead."-  MT-Safe\n"
	  \.lead."-  Non-copyable"
    let g:CppDox_instance           = "public:\n"
	  \."static ".a:clsname." & instance() {\n"
	  \."    static ".a:clsname." theInstance;\n"
	  \."    return theInstance;\n"
	  \."}"

  elseif type == 2 " explicit ctr, MT-safe
    let g:CppDox_constructors       = a:clsname."(".Marker_Txt("Parameters").");" 
    let g:CppDox_inherits           = ": private boost::noncopyable"
    let g:CppDox_private_members    = 
          \ "static ".a:clsname." *ms_instance;\n"
          \.g:CppDox_private_members
    let g:CppDox_semantics          =
	  \ lead."-  Explicitly initialized\n"
	  \.lead."-  MT-Safe\n"
	  \.lead."-  Non-copyable"
    let g:CppDox_instance           = "public:\n"
          \."/** Singleton accessor.\n"
	  \.lead.lh#dox#tag("pre")." ms_instance != 0\n"
	  \.lead.lh#dox#tag("throw")." None\n"
	  \." */\n"
	  \."static ".a:clsname." & instance() {\n"
	  \."    assert(ms_instance && \"Singleton not initialized.\");\n"
	  \."    return *ms_instance;\n"
	  \."}\n"
	  \."\n"
	  \."/** Singleton Construction.\n"
	  \.lead."This function is expected to be call from the main thread,"
          \.lead."before any other thread is created.\n"
	  \.lead.lh#dox#tag("pre")." ms_instance == 0\n"
	  \.lead.lh#dox#tag("post")." ms_instance != 0\n"
	  \.lead.lh#dox#tag("throw")." ".Marker_Txt("std::exception")."\n"
	  \." */\n"
	  \."static void create(".Marker_Txt("Parameters").") {\n"
	  \."    assert(!ms_instance && \"Singleton already initialized.\");\n"
	  \."    ms_instance = new ".a:clsname."(".Marker_Txt("Parameters").");\n"
	  \."}\n"
	  \."\n"
	  \."/** Singleton Destruction.\n"
	  \.lead.lh#dox#tag("pre")." ms_instance != 0\n"
	  \.lead.lh#dox#tag("post")." ms_instance == 0\n"
	  \.lead.lh#dox#tag("throw")." None\n"
	  \." */\n"
	  \."static void release() {\n"
	  \."    assert(ms_instance && \"Singleton not initialized.\");\n"
	  \."    delete ms_instance; \n"
	  \."    ms_instance = 0;\n"
	  \."}\n"
    let g:CppDox_stuff_for_cpp_file =
          \ " // don't forget to move the following definition to ".expand('%:t:r').".cpp\n"
          \.a:clsname." *".a:clsname."::ms_instance = 0;"
  endif

endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
