"=============================================================================
" File:         ftplugin/cpp/cpp_AddMissingScope.vim              {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      2.0.0b10
" Created:      25th Jun 2014
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Given an identifier under the cursor, search for its scope (namespace,
"       ...) and insert it.
" 
"------------------------------------------------------------------------
" }}}1
"=============================================================================

let s:k_version = 200
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_cpp_AddMissingScope")
      \ && (b:loaded_ftplug_cpp_AddMissingScope >= s:k_version)
      \ && !exists('g:force_reload_ftplug_cpp_AddMissingScope'))
  finish
endif
let b:loaded_ftplug_cpp_AddMissingScope = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

nnoremap <buffer> <silent> <Plug>AddMissingScope :call lh#cpp#scope#_add_missing()<cr>
if !hasmapto('<Plug>AddMissingScope', 'n')
  nmap <buffer> <silent> <unique> <m-n> <Plug>AddMissingScope
endif

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_cpp_AddMissingScope")
      \ && (g:loaded_ftplug_cpp_AddMissingScope >= s:k_version)
      \ && !exists('g:force_reload_ftplug_cpp_AddMissingScope'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_cpp_AddMissingScope = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/cpp/«cpp_AddMissingScope».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.
" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
