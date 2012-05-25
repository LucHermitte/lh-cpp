"=============================================================================
" $Id$
" File:         ftplugin/c/c_complete_include.vim                 {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      001
" Created:      08th Nov 2011
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Mapping to complete #include filename not based on &path (as
"       |i_CTRL-X_CTRL-F| is).
"       The completion is based instead on {bg}:{ft_}_includes_path + &include
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/ftplugin/c
"       Requires Vim7+, lh-vim-lib 2.2.7+
"       «install details»
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:k_version = 2
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_c_complete_include")
      \ && (b:loaded_ftplug_c_complete_include >= s:k_version)
      \ && !exists('g:force_reload_ftplug_c_complete_include'))
  finish
endif
let b:loaded_ftplug_c_complete_include = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" Local mappings {{{2

inoremap <buffer> <Plug>CompleteIncludes <c-r>=<sid>Complete()<cr>
if !hasmapto('<Plug>CompleteIncludes', 'i')
  imap <buffer> <unique> <c-x>i <Plug>CompleteIncludes
endif

nnoremap <buffer> <Plug>OpenIncludes :call <sid>Open()<cr>
if !hasmapto('<Plug>OpenIncludes', 'n')
  nmap <buffer> <unique> <c-l>i <Plug>OpenIncludes
endif

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_c_complete_include")
      \ && (g:loaded_ftplug_c_complete_include >= s:k_version)
      \ && !exists('g:force_reload_ftplug_c_complete_include'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_c_complete_include = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/c/«c_complete_include».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.

" Function: s:Complete() {{{3
function! s:Complete()
  let prev = GetLikeCTRL_W()
  let paths = lh#dev#option#get("includes", &ft, &path)
  let files = lh#path#glob_as_list(paths, [prev.'*.h', prev.'*.hpp'])
  let files = map(files, 'lh#path#strip_start(v:val, paths)')
  call complete(col('.')-len(prev), files)
  return ''
endfunction

" Function: s:Open() {{{3
" built on top of SearchInRuntime
function! s:Open()
  try
    let path = &path
    let paths = lh#dev#option#get("includes", &ft, &path)
    exe 'set path+='.join(paths, ',')
    exe "normal \<c-w>f"
  finally
    let &path = path
  endtry
endfunction

" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
