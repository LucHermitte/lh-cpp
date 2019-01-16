"=============================================================================
" File:         ftplugin/cpp/cpp_AddMissingScope.vim              {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.1
let s:k_version = 221
" Created:      25th Jun 2014
" Last Update:  16th Jan 2019
"------------------------------------------------------------------------
" Description:
"       Given an identifier under the cursor, search for its scope (namespace,
"       ...) and insert it.
"
"------------------------------------------------------------------------
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
let s:cpo_save=&cpo
set cpo&vim
if &cp || (exists("b:loaded_ftplug_cpp_AddMissingScope")
      \ && (b:loaded_ftplug_cpp_AddMissingScope >= s:k_version)
      \ && !exists('g:force_reload_ftplug_cpp_AddMissingScope'))
  let &cpo=s:cpo_save
  finish
endif
let b:loaded_ftplug_cpp_AddMissingScope = s:k_version
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

nnoremap <buffer> <silent> <Plug>AddMissingScope :call lh#cpp#scope#_add_missing()<cr>
if !hasmapto('<Plug>AddMissingScope', 'n')
  nmap <buffer> <silent> <unique> <m-n> <Plug>AddMissingScope
endif

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
