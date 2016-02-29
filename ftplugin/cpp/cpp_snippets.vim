"=============================================================================
" File:         ftplugin/cpp/cpp_snippets.vim                            {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/License.md>
" Version:      2.2.0
let s:k_version = '220'
" Created:      15th Apr 2008
" Last Update:  28th Feb 2016
"------------------------------------------------------------------------
" Description:  Snippets of C++ Control Statements
"
"------------------------------------------------------------------------
" History:
" for changelog: 13th Dec 2005 -> little bug in vmaps for ,,sc ,,rc ,,dc ,,cc
" for changelog: 15th Feb 2006 -> abbr for firend -> friend
" for changelog: 10th Apr 2006 -> "typename" after commas as well
" for changelog: 12th Jun 2006 -> <m-t> is not expanded in comments/string
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if (exists("b:loaded_ftplug_cpp_snippets") && !exists('g:force_reload_ftplug_cpp_snippets')) || get(g:, 'lh_cpp_snippets', 1) == 0
  finish
endif
let s:cpo_save=&cpo
set cpo&vim
let b:loaded_ftplug_cpp_snippets = s:k_version
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
" This must be loaded before continuing
runtime! ftplugin/c/c_snippets.vim

" Local mappings {{{2
"
"------------------------------------------------------------------------
" Some C++ abbreviated Keywords {{{3
" ------------------------------------------------------------------------
" TODO: check whether the line is empty
Inoreab <buffer> pub <c-r>='public'.lh#cpp#snippets#insert_if_not_after(' ', ':\<CR\>', '[:,]')<cr>
Inoreab <buffer> pro <c-r>='protected'.lh#cpp#snippets#insert_if_not_after(' ', ':\<CR\>', '[:,]')<cr>
Inoreab <buffer> pri <c-r>='private'.lh#cpp#snippets#insert_if_not_after(' ', ':\<CR\>', '[:,]')<cr>

Iabbr <buffer> tpl template <

inoreab <buffer> vir virtual
cnoreab          firend friend
inoreab <buffer> firend friend
inoreab <buffer> delate delta

inoremap <buffer> <m-s> std::
inoremap <buffer> <expr> <m-b> (getline('.')=~'#\s*include') ? 'boost/' : 'boost::'
inoremap <buffer> <expr> <m-n> lh#cpp#snippets#current_namespace("\<m-n>")
" We don't want ? (\hat o) to be expanded in comments)
inoremap <buffer> <m-t> <c-r>=lh#map#insert_seq('<m-t>', '\<c-r\>=lh#cpp#snippets#typedef_typename()\<cr\>')<cr>


"------------------------------------------------------------------------
" Control statements {{{3
"------------------------------------------------------------------------
"--- namespace ---------------------------------------------------{{{4
"--,ns insert "namespace" statement
  Inoreabbr <buffer> namespace <C-R>=lh#cpp#snippets#insert_if_not_after('namespace ',
        \ '\<c-f\>namespace <+namespace+>{<++>}// namespace <+namespace+>', 'using')<cr>
  " Inoreabbr <buffer> namespace <C-R>=lh#cpp#snippets#insert_if_not_after('namespace ',
        " \ '\<c-f\>namespace !cursorhere! {!mark!}!mark!', 'using')<cr>
  vnoremap <buffer> <silent> <LocalLeader>ns
        \ <c-\><c-n>@=lh#dev#style#surround('namespace !cursorhere!{', '!mark!}!mark!',
        \ 0, 1, '', 1, 'namespace ')<cr>
      nmap <buffer> <LocalLeader>ns V<LocalLeader>ns

"--- try ---------------------------------------------------------{{{4
"--try insert "try" statement
  command! -nargs=0 PrivateCppSearchTry :call search('try\_s*{\_s*\zs$', 'b')
  " Inoreabbr <buffer> <silent> try <C-R>=lh#cpp#snippets#def_abbr('try ',
        " \ '\<c-f\>try{!cursorhere!}catch(!mark!){!mark!}!mark!\<esc\>')<CR>
  Inoreabbr <buffer> <silent> try <C-R>=lh#cpp#snippets#def_abbr('try ',
        \ '\<c-f\>try{}catch(!mark!){!mark!}!mark!\<esc\>'
        \ .':PrivateCppSearchTry\<cr\>a\<c-f\>')<CR>
        "
        " \ .'?try\\_s*\\zs{\<cr\>:PopSearch\<cr\>o')<CR>
        " pb with prev. line: { is replaced by \n when c_nl_before_curlyB=1
        "
        " pb with next line: !cursorhere! is badly indented
        " \ '\<c-f\>try {!cursorhere!} catch (!mark!) {!mark!}!mark!')<cr>
"--,try insert "try - catch" statement
  vnoremap <buffer> <LocalLeader>try
        \ <c-\><c-n>@=lh#dev#style#surround('try{!cursorhere!', '!mark!}catch(!mark!){!mark!}',
        \ 0, 1, '', 1, 'try ')<cr>
      nmap <buffer> <LocalLeader>try V<LocalLeader>try

"--- catch -------------------------------------------------------{{{4
"--catch insert "catch" statement
  Inoreabbr <buffer> catch <C-R>=lh#cpp#snippets#def_abbr('catch ',
        \ '\<c-f\>catch(!cursorhere!){!mark!}!mark!')<cr>
  vnoremap <buffer> <LocalLeader>catch
        \ <c-\><c-n>@=lh#dev#style#surround('catch(!cursorhere!){', '!mark!}',
        \ 0, 1, '', 1, 'catch ')<cr>
      nmap <buffer> <LocalLeader>catch V<LocalLeader>catch
  vnoremap <buffer> <LocalLeader><LocalLeader>catch
        \ <c-\><c-n>@=lh#dev#style#surround('catch(', '!cursorhere!){!mark!}',
        \ 0, 1, '', 1, 'catch ')<cr>
      nmap <buffer> <LocalLeader><LocalLeader>catch V<LocalLeader><LocalLeader>catch

"------------------------------------------------------------------------
" Castings {{{3
"------------------------------------------------------------------------

" TODO: have s:k_cast_fmt be a [bg]:({ft}_) option.
let s:k_cast = {
      \ 'sc': 'static_cast',
      \ 'dc': 'dynamic_cast',
      \ 'cc': 'const_cast',
      \ 'rc': 'reinterpret_cast',
      \ 'lc': 'boost::lexical_cast'
      \ }

"  ,*c -> surround selection/current with "cast<«cursor»>(«selection»)>"
" 2,*c -> surround selection/current with "cast<«selection»>(«cursor»)>"
for cast in ['sc', 'cc', 'rc', 'dc', 'lc']
  exe 'vnoremap <silent> <buffer> <LocalLeader>'.cast
        \ ." <c-\\><c-n>@=lh#dev#style#surround('".s:k_cast[cast]."<!cursorhere!>(', '!mark!)',"
        \ ."0, 0, '', 1, '".s:k_cast[cast]."<')<cr>"
  exe '    nmap <silent> <buffer> <LocalLeader>'.cast.' viw<LocalLeader>'.cast
endfor

" ,*c -> change the C cast selected into the C++ cast
for cast in ['sc', 'cc', 'rc', 'dc']
  exe 'vnoremap <silent> <buffer> <LocalLeader><LocalLeader>'.cast
        \ ." <c-\\><c-n>:'<,'>call lh#cpp#snippets#_convert_to_cpp_cast('".cast."')<cr>"
  exe '    nmap <silent> <buffer> <LocalLeader><LocalLeader>'.cast.' viw<LocalLeader><LocalLeader>'.cast
endfor
"

"------------------------------------------------------------------------
" Misc {{{3
"------------------------------------------------------------------------
"--- Std oriented stuff-------------------------------------------{{{4
" In std::foreach and std::find algorithms, ..., expand 'algo(container?)'
" into:
" TODO: support begin(container) (std:: or boost::) as well
" - 'algo(container.begin(),container.end()?)',
" imap <buffer> <c-x>be .<esc>ci,<c-r>"begin(),<c-r>"end()
imap <buffer> <c-x>be <c-r>=lh#cpp#snippets#_begin_end('begin')<cr>
xmap <buffer> <c-x>be <c-\><c-n>ci,<c-r>".begin(),<c-r>".end()
nmap <buffer> <c-x>be viw<c-x>be

" - 'algo(container.rbegin(),container.rend()?)',
imap <buffer> <c-x>rbe <c-r>=lh#cpp#snippets#_begin_end('rbegin')<cr>
xmap <buffer> <c-x>rbe <c-\><c-n>ci,<c-r>".rbegin(),<c-r>".rend()
nmap <buffer> <c-x>rbe viw<c-x>rbe

" - 'algo(container.cbegin(),container.cend()?)',
imap <buffer> <c-x>cbe <c-r>=lh#cpp#snippets#_begin_end('cbegin')<cr>
xmap <buffer> <c-x>cbe <c-\><c-n>ci,<c-r>".cbegin(),<c-r>".cend()
nmap <buffer> <c-x>cbe viw<c-x>cbe


" '?' represents the current position of the cursor.

" Local commands {{{2

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if exists("g:loaded_ftplug_cpp_snippets") && !exists('g:force_reload_ftplug_cpp_snippets')
  let &cpo=s:cpo_save
  finish
endif
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Functions {{{2
" See autoload/lh/cpp/snippets.vim
" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
