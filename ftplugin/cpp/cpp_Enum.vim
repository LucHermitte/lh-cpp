"=============================================================================
" File:         ftplugin/cpp/cpp_Enum.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/tree/master/License.md>
" Version:      2.2.1
let s:k_version = 221
" Created:      30th Apr 2014
" Last Update:  16th Jan 2019
"------------------------------------------------------------------------
" Description:
"       Defines the command
"         :InsertEnum [<EnumName>] [Enum Values...]
"       which insert a smart enum (the one defined in cpp/enum2)
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
let s:cpo_save=&cpo
set cpo&vim
if &cp || (exists("b:loaded_ftplug_cpp_Enum")
      \ && (b:loaded_ftplug_cpp_Enum >= s:k_version)
      \ && !exists('g:force_reload_ftplug_cpp_Enum'))
  let &cpo=s:cpo_save
  finish
endif
let b:loaded_ftplug_cpp_Enum = s:k_version
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=* InsertEnum call lh#cpp#enum#_new(<f-args>)

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
