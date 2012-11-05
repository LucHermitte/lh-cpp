"=============================================================================
" $Id$
" File:         ftplugin/c/c_gcov.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      001
" Created:      30th Oct 2012
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       ftplugin to swap between a .gcov file and its source
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/ftplugin/c
"       Requires Vim7+
"       «install details»
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:k_version = 1
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_c_gcov")
      \ && (b:loaded_ftplug_c_gcov >= s:k_version)
      \ && !exists('g:force_reload_ftplug_c_gcov'))
  finish
endif
let b:loaded_ftplug_c_gcov = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

nnoremap <buffer> <localleader>g :call <sid>JumpOrToggleGCOVFile(expand('%:p'), 'e')<cr>

"------------------------------------------------------------------------
" Local commands {{{2


"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_c_gcov")
      \ && (g:loaded_ftplug_c_gcov >= s:k_version)
      \ && !exists('g:force_reload_ftplug_c_gcov'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_c_gcov = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/c/«c_gcov».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.
" Function: s:FindGCOVFile(source_file) {{{3
let s:k_gcov_ext = '.gcov'
function! s:FindGCOVFile(source_file)
  let current_file = fnamemodify(a:source_file, ':t')
  let current_path = fnamemodify(a:source_file,':p:h')
  let gcov_files_path = lh#dev#option#get('gcov_files_path', &ft, current_path)
  let files = lh#path#glob_as_list(gcov_files_path, current_file.s:k_gcov_ext)
  if empty(files)
    throw "Cannot find <".current_file.s:k_gcov_ext."> in ".string(files).". Please set b:[{ft}_]gcov_files_path"
  else
    let gcov_file = lh#path#select_one(files, "Which gcov file matches <".current_file."> ?")
    return gcov_file
  endif
endfunction

function! s:JumpOrToggleGCOVFile(source_file, cmd)
  let gcov_file = s:FindGCOVFile(a:source_file)
  call lh#buffer#jump(gcov_file, a:cmd)
endfunction
" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
