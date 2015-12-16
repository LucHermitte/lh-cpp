"=============================================================================
" File:         syntax/c-fallthrough-case.vim                     {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.0.
let s:k_version = '217'
" Created:      16th Dec 2015
" Last Update:  16th Dec 2015
"------------------------------------------------------------------------
" Description:  C syntax enhancements
" (*) Hightlights cases that fall through other cases
"
" Option:
" - |c_no_hl_fallthrough_case| to disable the check
"   Disabled by default
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
if !get(g:, 'c_no_hl_fallthrough_case', 1)
  silent! syn clear cFallthroughCase

  " These are usually defined as keywords, but we don't want their
  " |:syn-priority| to be higher => we redefine them as |:syn-match|
  syn clear	cLabel
  silent! syn clear	cBadLabel
  syn match	cBadLabel	/\v<default>/ containedin=cFallthroughCase
  syn match	cBadLabel	/\v<case>/ containedin=cFallthroughCase
  syn match	cLabel	/\v<default>/
  syn match	cLabel	/\v<case>/

  " FIXME: "break;} case" is incorrectly recognized
  " FIXME: "default:" is not recognized
  syn match	cFallthroughCase	/\v(((<break>|<continue>|<goto>\_s+\w+|return.*)\_s*;(\_s*})*|\{|\[\[fallthrough]])\_s*)@<!(<case>\_s+\w+|<default>)\s*:/  contains=cBadLabel

  hi def link	cFallthroughCase	spellBad
  hi def link	cBadLabel	badLabel
  hi badLabel term=reverse,bold ctermfg=3 ctermbg=9 gui=undercurl,bold guisp=Red guifg=Brown
endif
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
