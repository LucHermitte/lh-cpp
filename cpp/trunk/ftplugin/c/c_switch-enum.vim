"=============================================================================
" $Id$
" File:		ftplugin/c/c_switch-enum.vim                             {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	24th Jun 2006
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:
" 	Build a switch statement from all the possible values that define an
" 	enum.
" 
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" 	Drop into {rtp}/ftplugin/c/
" Requirements:
" 	Vim 7.0+
" 	lh-map-tool (misc_map.vim ad bracketing.base.vim)
" 	word_tools.vim
"
" TODO:		
"	- C typedef definitions
"	  -> typedef enum <faculative name> { ... } <type-alias>;
"	- Make the mapping customizable with <Plug>
"	- recognize the enum type of an enum variable (indirections)
"	- Work with embedded C++ scopes
" Cannot manage:
" - enumarated value orders
"
" }}}1
"=============================================================================

" Vim 7.0 required
if version < 700
  finish
endif

"=============================================================================
" Avoid buffer reinclusion {{{1
let s:cpo_save=&cpo
set cpo&vim
if exists('b:loaded_ftplug_switch_enum')
       \ && !exists('g:force_reload_switch_enum')
  let &cpo=s:cpo_save
  finish
endif
let b:loaded_ftplug_switch_enum = 1
 
" }}}1
"------------------------------------------------------------------------
" Commands and mappings {{{1
inoremap <buffer> <silent> <c-x>se <c-r>=<sid>SwitchEnum()<cr>
 
" Commands and mappings }}}1
"=============================================================================
" Avoid global reinclusion {{{1
if exists("g:loaded_switch_enum") 
      \ && !exists('g:force_reload_switch_enum')
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_switch_enum = 1
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Functions {{{1

function! s:SwitchEnum()
  let enum_name = GetCurrentKeyword()
  split  " search in another window
  let found = searchdecl(enum_name, 1)
  echomsg "`".enum_name."' found=".(found==0?'yes':'no')
  if found != 0 " not found
    quit " close the search window
    throw "C_SwitchEnum: Cannot find declaration of `".enum_name."'"
  endif

  let s:skip_comments = 'synIDattr(synID(line("."), col("."), 0), "name") =~?'
	\ . '"string\\|comment\\|doxygen"'
  " Found
  let first_line = line('.')
  let last_line = searchpair(
	\ 'enum\s*'.enum_name.'\s*{',
	\ '',
	\ '}',
	\ 'W', s:skip_comments)

  if last_line <= 0
    quit " close the search window
    throw "C_SwitchEnum: Cannot find definition of `".enum_name."'"
  endif
  " Extract the lines of the definition
  let definition = ''
  let l = first_line
  while l <= last_line
    let definition .= getline(l)
    let l = l + 1
  endwhile
  quit

  " Get rid of comments
  " todo, see cpp_GotoImpl.vim

  " Get rid of brackets
  let definition = matchstr(definition, '.*{\zs.*\ze\}')
  " Get rid of spaces
  let definition = substitute(definition, '\s*', '', 'g')

  " List of enumerated values
  let enums = split(definition, ',')

  " Get rid of value definitions (value=constant)
  call map(enums, "matchstr(v:val, '[^;=]*')")

  " Build the cases
  call map(enums, "'case '.v:val.':\r".Marker_Txt('code').";\rbreak;'")

  let to_be_inserted = "switch (!cursorhere!) \r{\r"
	\ . join(enums, "\r")
	\ . "\rdefault:\r".Marker_Txt('code').";\rbreak;\r}!mark!"
  return "\<c-w>".InsertSeq(enums, to_be_inserted)
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
