"=============================================================================
" $Id$
" File:		syntax/c-assign-in-condition.vim                         {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	08th Oct 2007
" Last Update:	$Date$
"------------------------------------------------------------------------
" Purpose:	C syntax enhancements
" 	(*) Hightlights assignements in if(), while(), ..., conditions
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
" Requirements:
" 	None
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

  syn match cAssignInConditionBad  '\(\s*if\_s*([^=!<>]*\)\@<==[^=][^,)]*'
  syn match cAssignInConditionRare '\(\s*while\_s*([^=!<>]*\)\@<==[^=][^,)]*'

  hi def link cAssignInConditionBad    SpellBad
  hi def link cAssignInConditionRare   SpellRare
endif


" ========================================================================
" {{{1 Some mappings

" ========================================================================
" vim: set foldmethod=marker:
