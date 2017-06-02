"=============================================================================
" File:         ftplugin/c/c_show_scope.vim                       {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"               <URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.0.
let s:k_version = '220'
" Created:      29th May 2017
" Last Update:  02nd Jun 2017
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
if &cp || (exists("b:loaded_ftplug_c_show_scope")
      \ && (b:loaded_ftplug_c_show_scope >= s:k_version)
      \ && !exists('g:force_reload_ftplug_c_show_scope'))
  finish
endif
let b:loaded_ftplug_c_show_scope = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

nnoremap <silent> <buffer> <localleader>sc :echo lh#cpp#analyse#context()<cr>

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_c_show_scope")
      \ && (g:loaded_ftplug_c_show_scope >= s:k_version)
      \ && !exists('g:force_reload_ftplug_c_show_scope'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_c_show_scope = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/c/«c_show_scope».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
