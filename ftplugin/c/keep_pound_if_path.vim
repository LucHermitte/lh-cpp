"=============================================================================
" File:         ftplugin/c/keep_pound_if_path.vim                 {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.1.
let s:k_version = '221'
" Created:      30th Jun 2016
" Last Update:  16th Jan 2019
"------------------------------------------------------------------------
" Description:
"    Remove the true/false path into a `#if ... #else ... #endif` construct
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
if &cp || (exists("b:loaded_ftplug_keep_pound_if_path")
      \ && (b:loaded_ftplug_keep_pound_if_path >= s:k_version)
      \ && !exists('g:force_reload_ftplug_keep_pound_if_path'))
  let &cpo=s:cpo_save
  finish
endif
let b:loaded_ftplug_keep_pound_if_path = s:k_version
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=1 KeepPoundIfPath call lh#cpp#macros#keep(<f-args>)

"=============================================================================
"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
