"=============================================================================
" File:         ftplugin/c/c_show_scope.vim                       {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"               <URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.1.
let s:k_version = '221'
" Created:      29th May 2017
" Last Update:  16th Jan 2019
"------------------------------------------------------------------------
" Description:
"       Display the context on the current function/namespace/class/...
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
let s:cpo_save=&cpo
set cpo&vim
if &cp || (exists("b:loaded_ftplug_c_show_scope")
      \ && (b:loaded_ftplug_c_show_scope >= s:k_version)
      \ && !exists('g:force_reload_ftplug_c_show_scope'))
  let &cpo=s:cpo_save
  finish
endif
let b:loaded_ftplug_c_show_scope = s:k_version
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

nnoremap <silent> <buffer> <localleader>sc :<c-u>echo lh#cpp#analyse#context()<cr>

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
