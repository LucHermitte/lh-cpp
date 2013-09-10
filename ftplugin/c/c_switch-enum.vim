"=============================================================================
" $Id$
" File:		ftplugin/c/c_switch-enum.vim                             {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
" Created:	24th Jun 2006
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:
" 	Builds a switch statement from all the possible values that define an
" 	enum.
" 
"------------------------------------------------------------------------
" Requirements:
" 	Vim 7.0+
" 	lh-dev, mu-template, an up-to-date ctags database
" 	word_tools.vim
"
" TODO:		
"	- indirections with C typedef definitions
"	  -> typedef enum <faculative name> { ... } <type-alias>;
"	- Work with embedded C++ scopes
"	- Use libclang when available
" Cannot manage:
" - the order of enumerated values, try to see with libclang
"
" }}}1
"=============================================================================

" Avoid buffer reinclusion {{{1
let s:cpo_save=&cpo
set cpo&vim
if exists('b:loaded_ftplug_switch_enum')
       \ && !exists('g:force_reload_c_switch_enum')
  let &cpo=s:cpo_save
  finish
endif
let b:loaded_ftplug_switch_enum = 200
 
" }}}1
"------------------------------------------------------------------------
" Commands and mappings {{{1
command! -b -nargs=0 SwitchEnum call lh#cpp#enum#expand_enum_to_switch()
inoremap <buffer> <silent> <Plug>SwitchEnum <c-\><c-n>:SwitchEnum<cr>
if !hasmapto('<Plug>SwitchEnum', 'i')
  imap <buffer> <silent> <unique> <c-x>se <Plug>SwitchEnum
endif

" Commands and mappings }}}1
"=============================================================================
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
