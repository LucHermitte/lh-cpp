"=============================================================================
" $Id$
" File:		ftplugin/c/c_brackets.vim                                {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
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
" 	Then, replace the calls to :Brackets
"
" 	Requires Vim7+, lh-map-tools, and {rtp}/autoload/lh/cpp/brackets.vim
"
" History:	
"	v1.0.0	19th Mar 2008
"		Exploit the new kernel from map-tools v1.0.0 
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
" }}}1
"=============================================================================


"=============================================================================
" Avoid buffer reinclusion {{{1
if exists('b:loaded_ftplug_c_brackets') && !exists('g:force_reload_ftplug_c_brackets')
  finish
endif
let b:loaded_ftplug_c_brackets = 1
 
let s:cpo_save=&cpo
set cpo&vim
" }}}1
"------------------------------------------------------------------------
" Brackets & all {{{
" ------------------------------------------------------------------------
if !exists(':Brackets')
  runtime plugin/common_brackets.vim
endif
" It seems that function() does not load anything ...
if !exists('lh#cpp#brackets#lt')
  runtime autoload/lh/cpp/brackets.vim
endif

if exists(':Brackets')
  let b:usemarks         = 1
  let b:cb_jump_on_close = 1
  " Re-run brackets() in order to update the mappings regarding the different
  " options.
  :Brackets { } -visual=0 -nl
  :Brackets { } -visual=0 -trigger=#{ 
  :Brackets { } -visual=1 -insert=0 -nl -trigger=<localleader>{
  :Brackets { } -visual=1 -insert=0

  :Brackets ( )
  :Brackets [ ] -visual=0
  :Brackets [ ] -insert=0 -trigger=<localleader>[
  :Brackets " " -visual=0 -insert=1
  :Brackets " " -visual=1 -insert=0 -trigger=""
  :Brackets ' ' -visual=0 -insert=1
  :Brackets ' ' -visual=1 -insert=0 -trigger=''
  :Brackets < > -open=function('lh#cpp#brackets#lt') -visual=0

  " :Brackets /* */ -visual=0
  " :Brackets /** */ -visual=0 -trigger=/!
  "
endif

"=============================================================================

" }}}
"=============================================================================
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
