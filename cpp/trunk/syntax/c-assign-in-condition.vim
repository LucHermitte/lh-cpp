"=============================================================================
" $Id$
" File:		syntax/c-assign-in-condition.vim                         {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	1.0.0
" Created:	08th Oct 2007
" Last Update:	$Date$
"------------------------------------------------------------------------
" Purpose:	C++ syntax enhancements
" 	(*) Hightlights assignements in if(), while(), ..., conditions
"
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" 	Installation Method 1:
"		Need to manualy patch $VIMRUNTIME/syntax/cpp.vim.
"		Add
"		    runtime! syntax/c-assign-in-condition.vim
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
" Requirements:
" 	word_tools.vim::GetCurrentKeyword()	-- unchecked
"
" Option:
" 	- |c_no_assign_in_condition| to disable the check that assignement are
" 	done in conditions.
" }}}1
" ========================================================================
" {{{1 Syntax definitions
"
" {{{2 Enforce catch by reference
if !exists("c_no_assign_in_condition")

  syn match cAssignInConditionBad  '\(\s*if\_s*([^=]*\)\@<==[^=][^,)]*'
  syn match cAssignInConditionRare '\(\s*while\_s*([^=]*\)\@<==[^=][^,)]*'

  hi def link cAssignInConditionBad    SpellBad
  hi def link cAssignInConditionRare   SpellRare
endif


" ========================================================================
" {{{1 Some mappings

" ========================================================================
" vim: set foldmethod=marker:
