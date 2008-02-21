"=============================================================================
" $Id$
" File:		syntax/cpp-funcdef.vim                                    {{{1
" Author:	Olivier Teuliere
" 		<URL:http://vim.wikia.com/wiki/Highlighting_of_method_names_in_the_definition>
" Maintainer:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	1.0.0
" Created:	23rd Jul 2007
" Last Update:	$Date$
"------------------------------------------------------------------------
" Purpose:	C++ syntax enhancements
" 	(*) Hightlights member-function definitions
"
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" 	Installation Method 1:
"		Need to manualy patch $VIMRUNTIME/syntax/cpp.vim.
"		Add
"		    runtime! syntax/cpp-funcdef.vim
"		or
"		    runtime! syntax/cpp-*.vim syntax/cpp_*.vim
"		after the call to
"		    runtime! syntax/c.vim
" 	Installation Method 2: (prefer this one)
" 		Define a {rtp}/syntax/cpp.vim (where {rtp} < $VIMRUNTIME) that
" 		contains:
"		    " This is the only valid way to load the C++ and C default syntax file.
"		    so $VIMRUNTIME/syntax/cpp.vim
"		    " Source C++ hooks
"		    runtime! syntax/cpp-*.vim syntax/cpp_*.vim
"
" Option:
" 	- |cpp_no_hl_funcdef| to disable the highlight
" }}}1
" ========================================================================
" {{{1 Syntax definitions
"
" {{{2 Load the standard C++ syntax file
so      $VIMRUNTIME/syntax/cpp.vim

" {{{2 Enforce catch by reference
if !exists("cpp_no_hl_funcdef")
  syn match cppFuncDef "::\~\?\zs\h\w*\ze([^)]*\()\s*\(const\)\?\)\?$" 

  hi def link cppFuncDef Special
endif

" ========================================================================

" ========================================================================
" vim: set foldmethod=marker:
