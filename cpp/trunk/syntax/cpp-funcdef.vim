"=============================================================================
" $Id$
" File:		syntax/cpp-funcdef.vim                                    {{{1
" Author:	Olivier Teuliere
" 		<URL:http://vim.wikia.com/wiki/Highlighting_of_method_names_in_the_definition>
" Maintainer:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	23rd Jul 2007
" Last Update:	$Date$
"------------------------------------------------------------------------
" Purpose:	C++ syntax enhancements
" 	(*) Hightlights member-function definitions
"
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" 	Installation Method:
" 		Define a {rtp}/syntax/c.vim (where {rtp} < $VIMRUNTIME) that
" 		contains:
"		    " This is the only valid way to load the C++ and C default syntax file.
"		    so $VIMRUNTIME/syntax/c.vim
"		    " Source C hooks
"		    runtime! syntax/c-*.vim syntax/c_*.vim
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
