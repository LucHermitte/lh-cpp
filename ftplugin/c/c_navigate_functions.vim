"=============================================================================
" $Id$
" File:         ftplugin/c/c_navigate_functions.vim {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      001
" Created:      08th Jul 2011
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       mappings ]m, ]M, [m and [M to navigate into functions begin/end
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/lh-cpp/ftplugin/c
"       Requires Vim7+, lh-dev
" History:      
" 08th Jul 2011: first implementation
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:k_version = 001
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_c_navigate_functions")
      \ && (b:loaded_ftplug_c_navigate_functions >= s:k_version)
      \ && !exists('g:force_reload_ftplug_c_navigate_functions'))
  finish
endif
let b:loaded_ftplug_c_navigate_functions = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

nnoremap <buffer> <Plug>NextFunctionStart :call <sid>NextFunction('s')<cr>
if !hasmapto('<Plug>NextFunctionStart', 'n')
      \ || exists('g:force_reload_ftplug_c_navigate_functions')
  nmap <buffer> ]m <Plug>NextFunctionStart
endif

nnoremap <buffer> <Plug>PrevFunctionStart :call <sid>PrevFunction('s')<cr>
if !hasmapto('<Plug>PrevFunctionStart', 'n')
      \ || exists('g:force_reload_ftplug_c_navigate_functions')
  nmap <buffer> [m <Plug>PrevFunctionStart
endif

nnoremap <buffer> <Plug>NextFunctionEnd :call <sid>NextFunction('e')<cr>
if !hasmapto('<Plug>NextFunctionEnd', 'n')
      \ || exists('g:force_reload_ftplug_c_navigate_functions')
  nmap <buffer> ]M <Plug>NextFunctionEnd
endif

nnoremap <buffer> <Plug>PrevFunctionEnd :call <sid>PrevFunction('e')<cr>
if !hasmapto('<Plug>PrevFunctionEnd', 'n')
      \ || exists('g:force_reload_ftplug_c_navigate_functions')
  nmap <buffer> [M <Plug>PrevFunctionEnd
endif

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_c_navigate_functions")
      \ && (g:loaded_ftplug_c_navigate_functions >= s:k_version)
      \ && !exists('g:force_reload_ftplug_c_navigate_functions'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_c_navigate_functions = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/c/«navigate_functions».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.

function! s:NextFunction(start_or_end)
  let line = line('.')
  let info = lh#dev#__FindFunctions(line)
  let crt_function = info.idx " function starting just after the current line
  let lFunctions   = info.fn

  if crt_function == -1
    throw "No known function after line ".line." in ctags base"
  endif

  let first_line = lFunctions[crt_function].line
  if a:start_or_end == 's'
    exe first_line
  else
    " we need to be sure the end of the previous function is < line
    let prev_end = lh#dev#__FindEndFunc(lFunctions[crt_function-1].line)[1]
    if prev_end <= line
      let last_line = lh#dev#__FindEndFunc(first_line)
      exe last_line[1]
    else
      exe prev_end
    endif
  endif
endfunction

function! s:PrevFunction(start_or_end)
  let line = line('.')
  let info = lh#dev#__FindFunctions(line)
  let crt_function = info.idx " function starting just after the current line
  let lFunctions   = info.fn

  if crt_function == 0
    throw "No known function before line ".line." in ctags base"
  endif

  let crt_function -= 1
  let first_line = lFunctions[crt_function].line
  if a:start_or_end == 's'
    while first_line >= line
      let crt_function -= 1
      let first_line = lFunctions[crt_function].line
    endwhile
    exe first_line
  else
    let last_line = lh#dev#__FindEndFunc(first_line)
    while last_line[1] >= line
      " "while" because sometimes tags are dedoubled
      let crt_function -= 1
      let first_line = lFunctions[crt_function].line
      let last_line = lh#dev#__FindEndFunc(first_line)
    endwhile
    exe last_line[1]
  endif
endfunction

" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
