" ========================================================================
" File:		ftplugin/cpp/cpp_FindContextClass.vim                 {{{1
" Author:	Luc Hermitte <MAIL:hermitte at free.fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Last Update:	10th Mar 2021
"------------------------------------------------------------------------
" Description:
" 	Library C++ ftplugin.
" 	It provides functions used by other C++ ftplugins.
" 	The theme of this library is the analysis of C++ scopes.
"
" Defines: {{{2
" (*) Function: Cpp_CurrentScope(lineNo, scope_type)
"     Returns the scope (class name or namespace name) at line lineNo.
"     scope_type can value: "any", "class" or "namespace".
" (*) Function: Cpp_SearchClassDefinition(lineNo)
"     Returns the class name of any member at line lineNo -- could be of the
"     form: "A::B::C" for nested classes.
"     Note: Outside class-scope, an empty string is returned
"     Note: Classes must be correctly defined: don't forget the ';' after the
"     '}'
" (*) Function Cpp_BaseClasses(lineNo)
"     Return the list of the direct base classes of the class around lineNo.
"     form: "+a_public_class, #a_protected_class, -a_private_class"
" }}}2
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" Dependencies:	VIM 6.0+

" History:	{{{2
" 	10th Mar 2021
" 	(*) Deprecate most functions as they have been moved to
" 	    autoload/cpp/AnalysisLib_Class.vim
" 	16th May 2006
" 	(*) Bug fix: "using namespace" was misdirecting Cpp_CurrentScope(), and
" 	    :GOTOIMPL as a consequence.
" 	29th Apr 2005
" 	(*) Not misdriven anymore by:
" 	    - forward declaration in namespaces
" 	      -> "namespace N {class foo;} namespace M{ class bar{}; }"
" 	09th Feb 2005
" 	(*) class_token += enum\|union
" 	(*) Not misdriven anymore by:
" 	    - consecutive classes
" 	      -> "namespace N {class foo {}; class bar{};}"
" 	    - comments
" 	16th dec 2002
" 	(*) Bug fixed regarding forwarded classes.
" 	16th oct 2002
" 	(*) Able to handle C-definitions like
" 	    "typedef struct foo{...} *PFoo,Foo;"
" 	(*) An inversion problem, with nested classes, fixed.
" 	(*) Cpp_SearchClassDefinition becomes obsolete. Instead, use
" 	    Cpp_CurrentScope(lineNo, scope_type) to search for a
" 	    namespace::class scope.
" 	11th oct 2002
" 	(*) Cpp_SearchClassDefinition supports:
" 	    - inheritance -> 'class A : xx B, xx C ... {'
" 	    - and declaration on several lines of the previous inheritance
" 	    text.
" 	(*) Functions that will return the list of the direct base classes of
" 	    the current class.
"
" TODO: {{{2
" (*) Support templates -> A<T>::B, etc
" (*) Find the list of every base class ; aim: be able to retrieve the list of
"     every virtual function available to the class.
" (*) Must we differentiate anonymous namespaces from the global namespace ?
" }}}1
" ==========================================================================
" No reinclusion {{{1
if exists("g:loaded_cpp_FindContextClass_vim")
      \ && !exists('g:force_load_cpp_FindContextClass')
  finish
endif
let g:loaded_cpp_FindContextClass_vim = 1
"" line continuation used here ??
let s:cpo_save = &cpo
set cpo&vim
" }}}1
" ==========================================================================
" Search for a class definition (not forwarded definition) {{{
" Function: Cpp_SearchClassDefinition(lineNo [, bNamespaces])
" Checks whether lineNo is in between the '{' at line classStart and its
" '}' counterpart ; in that case, returns "::".className
function! Cpp_SearchClassDefinition(lineNo,...) abort
  call lh#notify#deprecated('Cpp_SearchClassDefinition', 'lh#cpp#AnalysisLib_Class#SearchClassDefinition')
  return call('lh#cpp#AnalysisLib_Class#SearchClassDefinition', [a:lineNo]+a:000)
endfunction

" Possible Values:
"  - 'class'
"  - 'namespace'
"  - 'any'
function! Cpp_CurrentScope(lineNo, scope_type) abort
  call lh#notify#deprecated('Cpp_CurrentScope', 'lh#cpp#AnalysisLib_Class#CurrentScope')
  return lh#cpp#AnalysisLib_Class#CurrentScope(a:lineNo, a:scope_type)
endfunction
" }}}
" ==========================================================================
let &cpo = s:cpo_save
" ========================================================================
" vim60: set fdm=marker:
