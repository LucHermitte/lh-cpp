"=============================================================================
" File:		syntax/cpp-funcdef.vim                                    {{{1
" Author:	Olivier Teuliere
" 		<URL:http://vim.wikia.com/wiki/Highlighting_of_method_names_in_the_definition>
" Maintainer:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.0.
" Created:	23rd Jul 2007
" Last Update:	16th Dec 2015
"------------------------------------------------------------------------
" Purpose:	C++ syntax enhancements
" (*) Hightlights member-function definitions
"
"------------------------------------------------------------------------
" Option:
" - |cpp_no_hl_funcdef| to disable the highlight
" }}}1
" ========================================================================
" {{{1 Syntax definitions
"
" {{{2 Enforce catch by reference
if !get(g:, "cpp_no_hl_funcdef", 0)
  syn match cppFuncDef "::\~\?\zs\h\w*\ze([^)]*\()\s*\(const\)\?\)\?$"

  hi def link cppFuncDef Special
endif

" ========================================================================

" ========================================================================
" vim: set foldmethod=marker:
