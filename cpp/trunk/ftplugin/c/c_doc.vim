"=============================================================================
" $Id$
" File:		ftplugin/c/c_doc.vim                                      {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	v2.0.0
" Created:	22nd Jan 2004
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	Open documentation for C & C++ code
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:
"	v2.0.0  GPLv3 w/ exception + deprecation
" TODO:		
" - config variables to tell where to search the documentation
" - fix VAM dependencies if FixPathName is still used
" }}}1
"=============================================================================

" This plugin is deprecated for now.
" I'll have to clean it up, and permit to tune where to find the documentation
finish

"=============================================================================
" Local stuff {{{1
" Avoid buffer reinclusion {{{2
if exists('b:loaded_ftplug_c_doc')  && !exists('g:force_reload_c_doc')
  finish 
endif
let b:loaded_ftplug_c_doc = 1
 
let s:cpo_save=&cpo
set cpo&vim
" }}}2
"------------------------------------------------------------------------
" Commands and mappings {{{2

nnoremap <buffer> <C-F1> :CHelp <c-r><c-a><cr>
command! -buffer -nargs=1 CHelp :call s:CHelp(<f-args>)
 
" Commands and mappings }}}2
" }}}1
"=============================================================================
" Global stuff {{{1
" Avoid global reinclusion {{{2
if exists("g:loaded_c_doc") && !exists('g:force_reload_c_doc')
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_c_doc = 1
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
"
" s:Error               {{{3
function! s:Error(msg)
  if has('gui')
    call confirm(a:msg, '&Ok', 1, "Error")
  else
    echohl ErrorMsg
    echo a:msg
    echohl None
  endif
endfunction


" Load system_utils.vim {{{3
if !exists('*FixPathName')
  runtime plugin/system_utils.vim macros/system_utils.vim
endif
if !exists("*FixPathName")
  if has('gui')
    call confirm('<plugin/system_utils.vim> is not found on your system\n'.
	  \ 'Check for it on <http://hermitte.free.fr/vim/general.php>',
	  \ 'ok')
  else
    echohl ErrorMsg
    echo '<plugin/system_utils.vim> is not found on your system'
    echo 'Check for it on <http://hermitte.free.fr/vim/general.php>'
    echohl None
  endif
endif

" Definitions           {{{3
let s:std_doc = 'F:/Users/Luc/Prog/C++/docs/ref & cours/SL/www.dinkumware.com/htm_cpl/'

let s:boost_doc = 'F:/Users/Luc/Prog/C++/libs/boost_1_32_cvs/doc/html/'
let s:boost_lib = 'F:/Users/Luc/Prog/C++/libs/boost_1_32_cvs/libs/'

" s:Build_boost_url     {{{3
function! s:Build_boost_url(class)
  return s:boost_lib . a:class . '/index.html'
endfunction

" s:Build_std_url       {{{3
function! s:Build_std_url(class)
  " dinkumware doc
  exe 'sp '.s:std_doc.'_index.html'
  let l = 1
  let urls = ''
  while 1
    let l = search('<a HREF=.\{-}>.\{-}\<'.a:class.'</a>', 'W')
    if l <= 0 | break | endif
    let url = matchstr(getline(l), '"\zs[^<>]\{-}\ze">[^<>]\{-}\<'.a:class)
    let urls = urls . "\n" . url
  endwhile
  bw!
  let g:urls = urls
  let nb = strlen(substitute(urls, "[^\n]", '', 'g')) 
  if     nb == 0 | return ''
  elseif nb == 1 | return s:std_doc . strpart(urls, 1)
  else
    let n = confirm('chose:', strpart(urls, 1), 1)
    if n > 0 
      let url = matchstr(urls, '\%('."[^\n]*\n".'\)\{'.n.'}\zs'."[^\n]*")
      return s:std_doc . url
    endif
  endif
endfunction

" s:CHelp               {{{3
function! s:CHelp(WORD)
  let url = ''
  if     a:WORD =~ 'boost'
    let class = matchstr(a:WORD, 'boost::\zs[^()[<>.?]*\>')
    let url = s:Build_boost_url(class)
  elseif a:WORD =~ 'std'
    let class = matchstr(a:WORD, 'std::\zs[^()[<>.?]*\>')
    let url = s:Build_std_url(class)
  else
  endif

  if strlen(url)
    call s:DisplayInBrowser(url)
  endif
endfunction

" s:DisplayInBrowser    {{{3
function! s:DisplayInBrowser(url)
  if exists('g:html_browser')
    " ... into g:html_browser if specified
    call system(g:html_browser. " " . 
	  \ FixPathName(a:url,0,((&sh=~'sh')?"'":'"')))
  elseif has('win32')
    " ... into Ms's Internet Explorer ; for MsWindows only
    " :exe ':!start explorer ' . escape(FixPathName(a:url,0), '#')
    call system("explorer file:///" . 
	  \ FixPathName(a:url,0,((&sh=~'sh')?"'":'"')))
  else
    call s:Error('Please set <<g:html_browser>> '
	  \ . 'to the path of the browser you are using')
  endif
endfunction

" Functions }}}2
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
