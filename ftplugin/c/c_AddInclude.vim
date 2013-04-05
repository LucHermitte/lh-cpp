"=============================================================================
" $Id$
" File:         ftplugin/c/c_AddInclude.vim                       {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:      2.0.0
" Created:      22nd May 2012
" Last Update:  $Date$
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

let s:k_version = 200
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
function! s:TagsSelectPolicy()
  let select_policy = lh#option#get('tags_select', "expand('<cword>')", 'bg')
  return select_policy
endfunction

function! s:InsertInclude()
  let id = eval(s:TagsSelectPolicy())

  try
    let isk_save = &isk
    set isk-=:
    let info = taglist('.*\<'.id.'$')
  finally
    let &isk = isk_save
  endtry
  if len(info) == 0
    call lh#common#error_msg("insert-include: no tags for `".id."'")
    return
  endif
  " Filter for function definitions and #defines, ...
  let accepted_kinds = lh#dev#option#get('tag_kinds_for_inclusion', &ft, '[dfptcs]')
  call filter(info, "v:val.kind =~ ".string(accepted_kinds))
  " Filter for include files only
  let accepted_files = lh#dev#option#get('file_regex_for_inclusion', &ft, '\.h')
  call filter(info, "v:val.filename =~ ".string(accepted_files))
  " Is there any symbol left ?
  if len(info) == 0
    call lh#common#error_msg("insert-include: no acceptable tag for `".id."'")
    return
  endif
  " If there are several choices, ask which one to use.
  " But first: check the files.
  let info = lh#tags#uniq_sort(info)
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
  let filename = keys(files)[0] " this is the full filename
  echo filename
  let filename_simplify = lh#dev#option#get('filename_simplify_for_inclusion', &ft, ':t')
  let filename = fnamemodify(filename, filename_simplify)
  let l = search('^#\s*include\s*["<]'.filename)
  if l > 0
    call lh#common#warning_msg("insert-include: ".filename.", where `"
          \ .id."' is defined, is already included")
  else
    keepjumps normal! G
    call search('^#\s*include', 'b')
    if keys(files)[0] =~ '\<usr\>\|\<local\>'
      let line='#include <'.filename.'>'
    else
      let line='#include "'.filename.'"'
    endif
    put=line
  endif
  echo "Use CTRL-O to go back to previous cursor position" 
endfunction
" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
