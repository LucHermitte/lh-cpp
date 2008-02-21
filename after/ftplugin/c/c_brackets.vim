"=============================================================================
" $Id$
" File:		{rtp}/after/ftplugin/c/c_brackets.vim                   {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	1.0.0
" Created:	26th May 2004
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
" 	c-ftplugin that defines the default preferences regarding the
" 	bracketing mappings we want to use.
" 
"------------------------------------------------------------------------
" Installation:	
" 	This particular file is meant to be into {rtp}/after/ftplugin/c/
" 	In order to overidde these default definitions, copy this file into a
" 	directory that comes before the {rtp}/after/ftplugin/c/ you choosed --
" 	typically $HOME/.vim/ftplugin/c/ (:h 'rtp').
" 	Then, replace the assignements lines 43+
" History:	
"	v0.5    26th Sep 2007
"		No more jump on close
"	v0.4    25th May 2006
"	        Bug fix regarding the insertion of < in UTF-8
"	v0.3	31st Jan 2005
"		«<» expands into «<>!mark!» after: «#include», and after some
"		C++ keywords: «reinterpret_cast», «static_cast», «const_cast»,
"		«dynamic_cast», «lexical_cast» (from boost), «template» and
"		«typename[^<]*»
" TODO:		
" 	«<» in visual mode does not remove an indentation level anymore.
" }}}1
"=============================================================================


"=============================================================================
" Avoid buffer reinclusion {{{1
if exists('b:loaded_ftplug_c_brackets')
  finish
endif
let b:loaded_ftplug_c_brackets = 1
 
let s:cpo_save=&cpo
set cpo&vim
" }}}1
"------------------------------------------------------------------------
" Brackets & all {{{
" ------------------------------------------------------------------------
if !exists('*Brackets')
  runtime plugin/common_brackets.vim
endif
if exists('*Brackets')
  let b:cb_parent  = 1
  let b:cb_bracket = 1
  let b:cb_acco    = 1
  let b:cb_quotes  = 2
  let b:cb_Dquotes = 1
  let b:usemarks   = 1
  let b:cb_cmp     = 1
  let b:cb_ltFn    = "C_lt()"
  let b:cb_jump_on_close = 0
  " Re-run brackets() in order to update the mappings regarding the different
  " options.
  call Brackets()
endif

"=============================================================================
if exists('g:loaded_ftplug_c_brackets')
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_c_brackets = 1

" Callback function that specializes the behaviour of '<'
function! C_lt()
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, 0, c)
  if l =~ '^#\s*include\s*$'
	\ . '\|\U\{-}_cast\s*$'
	\ . '\|template\s*$'
	\ . '\|typename[^<]*$'
	" \ . '\|\%(lexical\|dynamic\|reinterpret\|const\|static\)_cast\s*$'
    if exists('b:usemarks') && b:usemarks
      return '<!cursorhere!>!mark!'
      " NB: InsertSeq with "\<left>" as parameter won't work in utf-8 => Prefer
      " "h" when motion is needed.
      " return '<>' . "!mark!\<esc>".strlen(Marker_Txt())."hi"
      " return '<>' . "!mark!\<esc>".strlen(Marker_Txt())."\<left>i"
    else
      " return '<>' . "\<Left>"
      return '<!cursorhere!>'
    endif
  else
    return '<'
  endif
endfunction


" }}}
"=============================================================================
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
