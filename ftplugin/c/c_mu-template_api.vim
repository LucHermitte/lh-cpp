"=============================================================================
" $Id$
" File:		ftplugin/c/c_mu-template_api.vim                          {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.0.0
" Created:	14th Apr 2006
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
" 	Provides API functions used in mu-template's C template-files.
"
" 	- C_nl_before_bracket() that returns the text to insert before a
" 	  bracket according to the option |g:c_nl_before_bracket|
" 	- C_nl_before_curlyB() that returns the text to insert before a
" 	  curly-bracket according to the option |g:c_nl_before_bracket|
" 
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" Dependancies:	mu-template (=> lh-map-tools, searchInRuntime)
" TODO: move to an autoload plugin
" }}}1
"=============================================================================

"=============================================================================
" Avoid global reinclusion {{{1
if exists("g:loaded_c_mu_template_api") 
      \ && !exists('g:force_reload_c_mu_template_api')
  finish 
endif
let g:loaded_c_mu_template_api = 1
let s:cpo_save=&cpo
set cpo&vim
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Functions {{{1

" note: The space is needed after the "\n" to avoid mu-template from joining
" the two next lines.
function! C_nl_before_bracket()
  return lh#cpp#option#nl_before_bracket() ? "\n " : " "
endfunction

function! C_nl_before_curlyB()
  return lh#cpp#option#nl_before_curlyB() ? "\n " : " "
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
