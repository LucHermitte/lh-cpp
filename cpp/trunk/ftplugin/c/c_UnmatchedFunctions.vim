"=============================================================================
" $Id$
" File:		ftplugin/c/c_UnmatchedFunctions.vim                       {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	14th Feb 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	«description»
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if exists("b:loaded_ftplug_c_UnmatchedFunctions") && !exists('g:force_reload_ftplug_c_UnmatchedFunctions')
  finish
endif
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

vnoremap <buffer> <c-x>u <c-\><c-n>:call <sid>DisplaySelected()<cr>
nmap <buffer> <c-x>u viw<c-x>u

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=? CppDisplayUnmatchedFunctions :call <sid>DisplayCmd(<q-args>)

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if exists("g:loaded_ftplug_c_UnmatchedFunctions") && !exists('g:force_reload_ftplug_c_UnmatchedFunctions')
  let &cpo=s:cpo_save
  finish
endif
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/cpp/«c_UnmatchedFunctions».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.

function! s:DisplaySelected()
  let a_save = @a
  try
    normal! gv"ay
    call lh#cpp#UnmatchedFunctions#Display(@a)
  finally
    let @a = a_save
  endtry
endfunction

function! s:DisplayCmd(...)
  if a:0 > 0 
    " todo: support option -file/-class
    let what 
	  \ = (a:1 =~ '-f\%[ile]') ? 'File'
	  \ : (a:1 =~ '-c\%[lass]') ? 'Class'
	  \ : a:1
  else
    let what = WHICH( 'CONFIRM',
	  \ "Displaying unmatched functions for the current ...",
	  \ "&Class\n&File\n&Abort", 1)
  endif
  let id = ''
  if what == 'Class'
    let id = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'), 'any')
  elseif what == 'File'
    let id = expand('%:t')
  elseif what != "" && what !='Abort'
    let id = what
  endif
  if strlen(id) > 0
    " echomsg 'lh#cpp#UnmatchedFunctions#Display('.id.')'
    call lh#cpp#UnmatchedFunctions#Display(id)
  else
    echohl WarningMsg
    echo 'abort'
    echohl None
  endif
endfunction

" Functions }}}2
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
