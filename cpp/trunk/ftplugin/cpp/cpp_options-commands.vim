"=============================================================================
" $Id$
" File:		ftplugin/cpp/cpp_options-commands.vim                     {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	10th oct 2002
" Last Update:	$Date$ (10th oct 2002)
"------------------------------------------------------------------------
" Description:
"	Some commands used to handle the local files cpp_options.vim
"
"	To define options for a project in a hierarchy tree, use |local_vimrc|
"	instead.
" 
"------------------------------------------------------------------------
" Installation:	Drop this files into $$/ftplugin/cpp/
" History:	{{{
" 	Version 1.0.0
" 	(*) Commands come from cpp_GotoFunctionImpl.vim
" }}}
" TODO:		Find a way to define options for a project or a hierarchy
" tree.
"=============================================================================
" Avoid reinclusion {{{
if exists('b:loaded_ftplug_cpp_options_commands_vim') | finish | endif
let b:loaded_ftplug_cpp_options_commands_vim = 1
"
let s:cpo_save=&cpo
set cpo&vim
" }}}
"------------------------------------------------------------------------
command! -buffer -nargs=0 CheckOptions :call <sid>CheckOptions()
 
"=============================================================================
" No reinclusion {{{
if exists("g:loaded_cpp_options_commands_vim") 
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_cpp_options_commands_vim = 1
" }}}
"------------------------------------------------------------------------
let s:esc_pwd = ''
" Function: s:CheckOptions() {{{ 
" Role: Checks whether we must reload the options file to match the current
" project.
function! s:CheckOptions()
  if s:esc_pwd != escape(getcwd(), '\')
    let s:pwd = getcwd()
    let s:esc_pwd = escape(s:pwd, '\')
    let g:do_load_cpp_options = 1
    if filereadable("./cpp_options.vim")
      so ./cpp_options.vim
      " elseif filereadable("$VIM/ftplugin/cpp/cpp_options.vim")
      " so $VIM/ftplugin/cpp/cpp_options.vim
    else 
      " so <sfile>:p:h/cpp_options.vim
      runtime ftplugin/cpp/cpp_options.vim
    endif
  endif
endfunction
" }}}
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
