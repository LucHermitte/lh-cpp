"=============================================================================
" $Id$
" File:         ftplugin/c/c_pvs-2-qf.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      200
" Created:      10th Jul 2012
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       «description»
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

let s:k_version = 200
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_c_pvs_2_qf")
      \ && (b:loaded_ftplug_c_pvs_2_qf >= s:k_version)
      \ && !exists('g:force_reload_ftplug_c_pvs_2_qf'))
  finish
endif
let b:loaded_ftplug_c_pvs_2_qf = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local commands {{{2

command! -b -nargs=1 -complete=file PVSLoad   call s:PVSLoad("<args>")
command! -b -nargs=* PVSIgnore call s:PVSAddFilters(<f-args>)
command! -b -nargs=+ PVSShow   call s:PVSDelFilters(<f-args>)
command! -b -nargs=0 PVSRedraw call s:ReDisplay()

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_c_pvs_2_qf")
      \ && (g:loaded_ftplug_c_pvs_2_qf >= s:k_version)
      \ && !exists('g:force_reload_ftplug_c_pvs_2_qf'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_c_pvs_2_qf = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/c/«c_pvs_2_qf».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.
let s:xsl = lh#path#glob_as_list(&rtp, 'script/PVS2qf.xsl')[0]
" Function: s:PVSLoad(plog) {{{3
function! s:PVSLoad(plog)
  let xsltproc = lh#option#get('xsltproc', 'xsltproc')
  if !executable(xsltproc)
    throw "Sorry <" . xsltproc . "> is not a valid executable. Please set g:xsltproc or $PATH"
  endif
  if !filereadable(a:plog)
    throw "PVS-Studio file <".a:plog."> cannot be read."
  endif
  let errors = system(xsltproc . ' ' . s:xsl . ' ' . a:plog)
  let errors = substitute(errors, '\n\|\r', '', 'g')
  silent! unlet s:qf
  let s:qf = eval(errors)
  call s:ReDisplay()
endfunction

if !exists('s:filters_nr') " filter for error numbers
  let s:filters_nr = []
endif

if !exists('s:filters_mess') " filter for messages
  let s:filters_mess = []
endif

" Function: s:PVSAddFilters(filters...) {{{3
function! s:PVSAddFilters(...)
  if len(a:000) == 0
    echo "Errors ignored are: " . join(map(copy(s:filters_nr), '"V".v:val'), ', ') . ', and messages containing: ' . join(s:filters_mess, ', ')
  else
    for pat in a:000
      if pat =~ '^\d\+$'
        let s:filters_nr += [pat]
      else
        let s:filters_mess += [pat]
      endif
    endfor
    call s:ReDisplay()
  endif
endfunction

" Function: s:PVSDelFilters(filters...) {{{3
function! s:PVSDelFilters(...)
  let to_remove_nr = []
  let to_remove_mess = []
  for pat in a:000
    if pat =~ '^\d\+$'
      let to_remove_nr += [pat]
    else
      let to_remove_mess += [pat]
    endif
  call filter(s:filters_nr, 'match(to_remove_nr, v:val) < 0')
  call filter(s:filters_mess, 'match(to_remove_mess, v:val) < 0')
  endfor
  call s:ReDisplay()
endfunction

" Function: s:ReDisplay() {{{3
function! s:ReDisplay()
  let qf = filter(copy(s:qf), 'match(s:filters_nr, v:val.nr)<0')
  call filter(qf, 'lh#list#find_if(s:filters_mess, escape(string(v:val.text), "[") . "=~ v:1_")<0')
  call setqflist(qf)
  Copen " from BTW
  call lh#common#warning_msg(len(qf).'/'.len(s:qf).' warnings found')
endfunction

" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
