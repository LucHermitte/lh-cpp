"=============================================================================
" File:         ftplugin/c/c_AddInclude.vim                       {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:      2.1.3
let s:k_version = 213
" Created:      22nd May 2012
" Last Update:  28th Oct 2015
"------------------------------------------------------------------------
" Description:
"       This ftplugin defines a mapping to insert missing includes (given we
"       know which symbol shall be defined...)
"
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/ftplugin/c
"       Requires Vim7+, lh-dev
" History:
"	v2.0.0  GPLv3 w/ exception
" TODO:
"       Handle the case where several files are found
"       Move to autoload plugin
"       Recognize commented includes
" }}}1
"=============================================================================

finish " This ftplugin has been deprecated in favour of lh-dev/ImportModule feature
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_c_AddInclude")
      \ && (b:loaded_ftplug_c_AddInclude >= s:k_version)
      \ && !exists('g:force_reload_ftplug_c_AddInclude'))
  finish
endif
let b:loaded_ftplug_c_AddInclude = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

nnoremap <silent> <buffer> <Plug>InsertInclude :call <sid>InsertInclude()<cr>
if !hasmapto('<Plug>InsertInclude', 'n')
  nmap <silent> <buffer> <unique> <c-x>i <Plug>InsertInclude
endif

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_c_AddInclude")
      \ && (g:loaded_ftplug_c_AddInclude >= s:k_version)
      \ && !exists('g:force_reload_ftplug_c_AddInclude'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_c_AddInclude = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/c/«c_AddInclude».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.
function! s:InsertInclude() abort
  " If there are several choices, ask which one to use.
  " But first: check the files.
  let [id, info] = lh#cpp#tags#fetch("insert-include")

  let files = {}
  for t in info
    if ! has_key(files, t.filename)
      let files[t.filename] = {}
    endif
    let files[t.filename][t.kind[0]] = ''
  endfor
  " NB: there shouldn't be any to prioritize between p and f kinds as the
  " filtering on include files shall get rid of the f kinds (that exist along
  " with a prototype)
  if len(files) > 1
    call lh#common#error_msg("insert-include: too many acceptable tags for `"
          \ .id."': ".string(files))
    return
  endif
  mark '
  let fullfilename = keys(files)[0]
  let filename = fullfilename " this is the full filename
  " echo filename
  try
    call lh#cpp#include#add(filename, fullfilename=~ '\<usr\>\|\<local\>')
  catch /^insert-include:.* is already included/
    call lh#common#warning_msg("insert-include: ".filename.", where `"
          \ .id."' is defined, is already included")
  endtry
  echo "Use CTRL-O to go back to previous cursor position"
endfunction

" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
