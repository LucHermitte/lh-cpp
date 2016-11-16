"=============================================================================
" File:         ftplugin/c/c_complete_include.vim                 {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      2.2.0
let s:k_version = 220
" Created:      08th Nov 2011
" Last Update:  16th Nov 2016
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

inoremap <silent> <buffer> <Plug>CompleteIncludes <c-r>=<sid>Complete()<cr>
if !hasmapto('<Plug>CompleteIncludes', 'i')
  imap <buffer> <unique> <c-x>i <Plug>CompleteIncludes
endif

nnoremap <silent> <buffer> <Plug>OpenIncludes :call <sid>Open()<cr>
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
  let cleanup = lh#on#exit()
        \.restore('&isk')
  try
    set isk+=/
    let prev = GetLikeCTRL_W()
  finally
    call cleanup.finalize()
  endtry
  let paths = lh#cpp#tags#get_included_paths(&path)
  let files = lh#path#glob_as_list(paths, [prev.'*'])
  " Keep headers files and directories
  call filter(files, 'v:val =~? "\\v\.(h|hpp|hxx|txx|h\\+\\+)$" || isdirectory(v:val)')
  call map(files, 'v:val . (isdirectory(v:val)?"/":"")')
  let files = lh#list#unique_sort(files)
  let entries = map(copy(files), '{"word": lh#path#strip_start(v:val, paths), "menu": v:val}')
  call lh#icomplete#new(col('.')-lh#encoding#strlen(prev)-1, entries, []).start_completion()
  return ''
endfunction

" Function: s:Open() {{{3
" built on top of SearchInRuntime
function! s:Open()
  try
    let path = &path
    let paths = lh#cpp#tags#get_included_paths()
    exe 'set path+='.join(paths, ',')
    exe "normal \<c-w>f"
  finally
    let &path = path
  endtry
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
