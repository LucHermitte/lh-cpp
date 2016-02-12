"=============================================================================
" File:		syntax/c-assign-in-condition.vim                         {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:	2.2.0
" Created:	08th Oct 2007
" Last Update:	16th Dec 2015
"------------------------------------------------------------------------
" Purpose:	C syntax enhancements
"  (*) Hightlights assignements in if(), while(), ..., conditions
"
"------------------------------------------------------------------------
" Requirements:
" 	None
"
" Option:
" - |c_no_assign_in_condition| to disable the check that assignments are
"   done in conditions.
" }}}1
" ========================================================================
" {{{1 Syntax definitions
"
" {{{2 Don't assign in conditions
if !get(g:, "c_no_assign_in_condition", 0)

  syn match cAssignInConditionBad  '\(\<if\_s*([^=!<>]*\)\@<==[^=][^,)]*'
  syn match cAssignInConditionRare '\(\<while\_s*([^=!<>]*\)\@<==[^=][^,)]*'

  hi def link cAssignInConditionBad    SpellBad
  hi def link cAssignInConditionRare   SpellRare
endif


" ========================================================================
" {{{1 Some mappings

" }}}1
" ========================================================================
" vim: set foldmethod=marker:
