" ========================================================================
" $Id$
" File:		cpp_set.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://hermitte.free.fr/vim/>
" Version:	1.0.0
" Last Update:	$Date$
"
"------------------------------------------------------------------------
" Description:	
" 	Defines mappings and options for C++ programming.
"
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" Dependencies:	c_set.vim, misc_map.vim, 
" 		cpp_InsertAccessors.vim,
" 		cpp_BuildTemplates.vim
" 		VIM >= 6.00 only
"
" TODO:		
"  * Menus & Help pour se souvenir des commandes possibles
"  * Support pour l'héritage vis-à-vis des constructeurs
"  * Reconnaître si la classe courante est template vis-à-vis des
"    implementations & inlinings
" }}}1
" ========================================================================

" for changelog: 13th Dec 2005 -> little bug in vmaps for ,,sc ,,rc ,,dc ,,cc
" for changelog: 15th Feb 2006 -> abbr for firend -> friend
" for changelog: 10th Apr 2006 -> "typename" after commas as well
" for changelog: 02nd Jun 2006 -> suffixesadd
" for changelog: 12th Jun 2006 -> <m-t> is not expanded in comments/string

" ========================================================================
" Buffer local definitions {{{1
" ========================================================================
if exists("b:loaded_local_cpp_settings") && !exists('g:force_reload_cpp_ftp')
  finish 
endif
let b:loaded_local_cpp_settings = 1

"" line continuation used here ??
let s:cpo_save = &cpo
set cpo&vim

" ------------------------------------------------------------------------
" Commands {{{2
" ------------------------------------------------------------------------
" Cf. cpp_BuildTemplates.vim
"
" ------------------------------------------------------------------------
" VIM Includes {{{2
" ------------------------------------------------------------------------
if exists("b:did_ftplugin")
  unlet b:did_ftplugin
endif
source $VIMRUNTIME/ftplugin/cpp.vim
let b:did_ftplugin = 1
" runtime! ftplugin/c/*.vim 
" --> need to be sure that some definitions are loaded first!
"     like maplocaleader.

""so $VIMRUNTIME/macros/misc_map.vim

"   
" ------------------------------------------------------------------------
" Options to set {{{2
" ------------------------------------------------------------------------
"  setlocal formatoptions=croql
"  setlocal cindent
"
setlocal cinoptions=g0,t0,h1s,i0
setlocal suffixesadd+=.hpp,.cpp,.C,.h++,.c++,.hh

" browse filter
if has("gui_win32") 
  let b:browsefilter = 
	\ "C++ Header Files (*.hpp *.h++ *hh)\t*.hpp;*.h++;*.hh\n" .
	\ "C++ Source Files (*.cpp *.c++)\t*.cpp;*.c++\n" .
	\ "C Header Files (*.h)\t*.h\n" .
	\ "C Source Files (*.c)\t*.c\n" .
	\ "All Files (*.*)\t*.*\n"
endif
" ------------------------------------------------------------------------
" Some C++ abbreviated Keywords {{{2
" ------------------------------------------------------------------------
Inoreab <buffer> pub public:<CR>
Inoreab <buffer> pro protected:<CR>
Inoreab <buffer> pri private:<CR>

Iabbr <buffer> tpl template <

inoreab <buffer> vir virtual
cnoreab          firend friend
inoreab <buffer> firend friend

inoremap <buffer> <m-s> std::
inoremap <buffer> <m-b> boost::
inoremap <buffer> <m-l> luc_lib::
" We don't want ô (\hat o) to be expanded in comments)
inoremap <buffer> <m-t> <c-r>=InsertSeq('<m-t>', '\<c-r\>=Cpp_TypedefTypename()\<cr\>')<cr>


"--- namespace ----------------------------------------------------------
"--,ns insert "namespace" statement              {{{
  Inoreabbr <buffer> namespace <C-R>=InsertIfNotAfter('namespace ',
	\ '\<c-f\>namespace !cursorhere! {!mark!\n}!mark!', 'using')<cr>
  vnoremap <buffer> <silent> <LocalLeader>ns 
	\ <c-\><c-n>@=Surround('namespace !cursorhere! {', '!mark!\n}!mark!', 
	\ 1, 1, '', 1, 'namespace ')<cr>
      nmap <buffer> <LocalLeader>ns V<LocalLeader>ns
" }}}

"--- try ----------------------------------------------------------------
"--try insert "try" statement                    {{{
	" \ .'?try\<cr\>o')<CR>
  command! -nargs=0 PrivateCppSearchTry :call search('try\_s*{\zs', 'b')
  Inoreabbr <buffer> <silent> try <C-R>=Def_AbbrC('try ',
	\ '\<c-f\>try {\n} catch (!mark!) {!mark!\n}!mark!\<esc\>'
	\ .':PrivateCppSearchTry\<cr\>o')<CR>
	" \ .'?try\\_s*\\zs{\<cr\>:PopSearch\<cr\>o')<CR>
	" pb with prev. line: { is replaced by \n when c_nl_before_curlyB=1
	"
	" pb with next line: !cursorhere! is badly indented
	" \ '\<c-f\>try {\n!cursorhere!\n} catch (!mark!) {!mark!\n}!mark!')<cr>
"--,try insert "try - catch" statement
  vnoremap <buffer> <LocalLeader>try 
	\ <c-\><c-n>@=Surround('try {!cursorhere!', '!mark!\n} catch (!mark!) {!mark!\n}', 
	\ 1, 1, '', 1, 'try ')<cr>
	" \ :call InsertAroundVisual('try {',"} catch () {\n}", 1, 1)<cr>gV
      nmap <buffer> <LocalLeader>try V<LocalLeader>try
" }}}

"--- catch --------------------------------------------------------------
"--catch insert "catch" statement                {{{
  Inoreabbr <buffer> catch <C-R>=Def_AbbrC('catch ',
	\ '\<c-f\>catch (!cursorhere!) {!mark!\n}!mark!')<cr>
	" \ '\<c-f\>catch () {!mark!\<cr\>}!mark!\<esc\>?)\<cr\>:PopSearch\<cr\>i')<CR>
  vnoremap <buffer> <LocalLeader>catch 
	\ <c-\><c-n>@=Surround('catch (!cursorhere!) {', '!mark!\n}', 
	\ 1, 1, '', 1, 'catch ')<cr>
      nmap <buffer> <LocalLeader>catch V<LocalLeader>catch
  vnoremap <buffer> <LocalLeader><LocalLeader>catch 
	\ <c-\><c-n>@=Surround('catch (', '!cursorhere!) {!mark!\n}', 
	\ 0, 1, '', 1, 'catch ')<cr>
      nmap <buffer> <LocalLeader><LocalLeader>catch V<LocalLeader><LocalLeader>catch
" }}}

"--- dynamic_cast -------------------------------------------------------
"--dc insert "dynamic_cast" keyword                {{{
  vnoremap <buffer> <LocalLeader>dc
	\ <c-\><c-n>@=Surround('dynamic_cast <!cursorhere!>(', '!mark!)', 
	\ 0, 0, '', 1, 'dynamic_cast<')<cr>
      nmap <buffer> <LocalLeader>dc viw<LocalLeader>dc

  vnoremap <buffer> <LocalLeader><LocalLeader>dc
	\ <c-\><c-n>:'<,'>call <sid>ConvertToCPPCast('dynamic_cast')<cr>
      nmap <buffer> <LocalLeader><LocalLeader>dc viw<LocalLeader><LocalLeader>dc
" }}}
"
"--- reinterpret_cast ---------------------------------------------------
"--rc insert "reinterpret_cast" keyword                {{{
  vnoremap <buffer> <LocalLeader>rc
	\ <c-\><c-n>@=Surround('reinterpret_cast <!cursorhere!>(', '!mark!)', 
	\ 0, 0, '', 1, 'reinterpret_cast<')<cr>
      nmap <buffer> <LocalLeader>rc viw<LocalLeader>rc

  vnoremap <buffer> <LocalLeader><LocalLeader>rc
	\ <c-\><c-n>:'<,'>call <sid>ConvertToCPPCast('reinterpret_cast')<cr>
      nmap <buffer> <LocalLeader><LocalLeader>rc viw<LocalLeader><LocalLeader>rc
" }}}
"
"--- static_cast --------------------------------------------------------
"--sc insert "static_cast" keyword                {{{
  vnoremap <buffer> <LocalLeader>sc
	\ <c-\><c-n>@=Surround('static_cast <!cursorhere!>(', '!mark!)', 
	\ 0, 0, '', 1, 'static_cast<')<cr>
      nmap <buffer> <LocalLeader>sc viw<LocalLeader>sc

  vnoremap <buffer> <LocalLeader><LocalLeader>sc
	\ <c-\><c-n>:'<,'>call <sid>ConvertToCPPCast('static_cast')<cr>
      nmap <buffer> <LocalLeader><LocalLeader>sc viw<LocalLeader><LocalLeader>sc
" }}}
"
"--- const_cast -------------------------------------------------------
"--cc insert "const_cast" keyword                {{{
  vnoremap <buffer> <LocalLeader>cc
	\ <c-\><c-n>@=Surround('const_cast <!cursorhere!>(', '!mark!)', 
	\ 0, 0, '', 1, 'const_cast<')<cr>
      nmap <buffer> <LocalLeader>cc viw<LocalLeader>cc

  vnoremap <buffer> <LocalLeader><LocalLeader>cc
	\ <c-\><c-n>:'<,'>call <sid>ConvertToCPPCast('const_cast')<cr>
      nmap <buffer> <LocalLeader><LocalLeader>cc viw<LocalLeader><LocalLeader>cc
" }}}
"
" ------------------------------------------------------------------------
" Comments ; Javadoc/DOC++/Doxygen style
" ------------------------------------------------------------------------
"
" /**       inserts /** <cursor>
"                    */
" but only outside the scope of C++ comments and strings
  inoremap <buffer> /**  <c-r>=Def_MapC('/**',
	\ '/**\<cr\>\<BS\>/\<up\>\<end\> ',
	\ '/**\<cr\>\<BS\>/!mark!\<up\>\<end\> ')<cr>
" /*<space> inserts /** <cursor>*/
  inoremap <buffer> /*<space>  <c-r>=Def_MapC('/* ',
	\ '/** */\<left\>\<left\>',
	\ '/** */!mark!\<esc\>F*i')<cr>


" }}}
"
" ------------------------------------------------------------------------
" Comments ; Javadoc/DOC++/Doxygen style {{{2
" ------------------------------------------------------------------------
"
" /**       inserts /** <cursor>
"                    */
" but only outside the scope of C++ comments and strings
  inoremap <buffer> /**  <c-r>=Def_MapC('/**',
	\ '/**\<cr\>\<BS\>/\<up\>\<end\> ',
	\ '/**\<cr\>\<BS\>/!mark!\<up\>\<end\> ')<cr>
" /*<space> inserts /** <cursor>*/
  inoremap <buffer> /*<space>  <c-r>=Def_MapC('/* ',
	\ '/** */\<left\>\<left\>',
	\ '/** */!mark!\<esc\>F*i')<cr>


" ------------------------------------------------------------------------
" std oriented stuff {{{2
" ------------------------------------------------------------------------
" In std::foreach and std::find algorithms, ..., expand 'algo(container§)'
" into:
" - 'algo(container.begin(),container.end()§)', 
inoremap <c-x>be .<esc>%v%<left>o<right>y%%ibegin(),<esc>paend()<esc>a
" - 'algo(container.rbegin(),container.rend()§)', 
inoremap <c-x>rbe .<esc>%v%<left>o<right>y%%irbegin(),<esc>parend()<esc>a

" '§' represents the current position of the cursor.

" ========================================================================
" General definitions {{{1
" ========================================================================
if exists("g:loaded_cpp_set") && !exists('g:force_reload_cpp_ftp')
  let &cpo = s:cpo_save
  finish 
endif
let g:loaded_cpp_set = 1

function! s:ConvertToCPPCast(cast_type)
  " Extract text to convert
  let save_a = @a
  normal! gv"ay
  " Strip the possible brackets around the expression
  let expr = matchstr(@a, '^(.\{-})\zs.*$')
  let expr = substitute(expr, '^(\(.*\))$', '\1', '')
  " 
  " Build the C++-casting from the C casting
  let new_cast = substitute(@a, '(\(.\{-}\)).*',
	\ a:cast_type.'<\1>('.escape(expr, '\&').')', '')
  " Do the replacement
  exe "normal! gvs".new_cast."\<esc>"
  let @a = save_a
endfunction

function! InsertIfNotAfter(key, what, pattern)
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, 0, c)
  if l =~ a:pattern.'\s*$'
    return a:key
  else 
    return Def_AbbrC(a:key, a:what)
  endif
endfunction

function! Cpp_TypedefTypename()
  return InsertIfNotAfter('typename ', 'typedef ', 'typedef\|<\|,')
endfunction

let &cpo = s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
