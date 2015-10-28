"=============================================================================
" File:         ftplugin/cpp/cpp_Enum.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:      2.0.0
" Created:      30th Apr 2014
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Defines the command
"         :InsertEnum [<EnumName>] [Enum Values...]
"       which insert a smart enum (the one defined in cpp/enum2)
" }}}1
"=============================================================================

let s:k_version = 200
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_cpp_Enum")
      \ && (b:loaded_ftplug_cpp_Enum >= s:k_version)
      \ && !exists('g:force_reload_ftplug_cpp_Enum'))
  finish
endif
let b:loaded_ftplug_cpp_Enum = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=* InsertEnum call lh#cpp#enum#_new(<f-args>)

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_cpp_Enum")
      \ && (g:loaded_ftplug_cpp_Enum >= s:k_version)
      \ && !exists('g:force_reload_ftplug_cpp_Enum'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_cpp_Enum = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/cpp/«cpp_Enum».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.
" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
