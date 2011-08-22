"=============================================================================
" $Id$
" File:		plugin/omap-param.vim                                     {{{1
" Maintainer:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Other Contributors:	A.Politz
" Version:	1.1.0
" Created:	03rd Sep 2007
" Last Update:	$Date$ (05th Sep 2007)
"------------------------------------------------------------------------
" Description:	
" 	Mappings for selecting functions parameters in various programming
" 	langages where parameters are passed within braces, separated by
" 	commas.
"
" See:
" 	:h objet-select
" 
"------------------------------------------------------------------------
" Installation:	
" 	Drop this file into {rtp}/plugin/
" 	Requires 
" 	- Vim 7+,
" 	- {rtp}/autoload/lh/position.vim
" 	- {rtp}/autoload/lh/syntax.vim
" History:	
" 	v0.9.0 first version
" Credits:
" 	<URL:http://vim.wikia.com/wiki/Indent_text_object>
" 	A.Politz
" TODO:		
" 	Move this into lh-vim-lib or a plugin.
" Notes:
" 	* "i," can't be used to select several parameters with several uses of
" 	"i," ; use "a," instead (-> "va,a,a,"). This is because of simple
" 	letter parameters.
" 	However, "v2i," works perfectly.
" 	* The following should be resistant to &magic, and other mappings
" 	* select-mode is not parasited by this plugin
" }}}1
"=============================================================================

if 0
  finish
  call Un(Null,fun2(fun3(a,b,g(NULL))),t, titi, r  , zzz
  call Un(Null,fun2(fun3(a,b,g(NULL))),t, titi,   , zzz)
endif

"=============================================================================
" Avoid global reinclusion {{{1
let s:cpo_save=&cpo
set cpo&vim
if exists("g:loaded_omap_param_vim") 
      \ && !exists('g:force_reload_omap_param_vim')
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_omap_param_vim = 1
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Public Mappings {{{1
onoremap <silent> i, :<c-u>call <sid>SelectParam(1,0)<cr>
xnoremap <silent> i, :<c-u>call <sid>SelectParam(1,1)<cr><esc>gv
onoremap <silent> a, :<c-u>call <sid>SelectParam(0,0)<cr>
xnoremap <silent> a, :<c-u>call <sid>SelectParam(0,1)<cr><esc>gv

" Private Functions {{{1
function! s:SelectParam(inner, visual)
  let saved_pos = getpos('.')
  if a:visual ==1 && lh#position#char_at_mark("'>") =~ '[(,]'  
	\ && !lh#syntax#skip_at_mark("'>")
    normal! gv
  elseif searchpair('(',',',')','bcW','lh#syntax#skip()') > 0 ||
	\ searchpair('(',',',')','bW','lh#syntax#skip()') > 0
    " Test necessary because 'c' flag and Skip() don't always work well together
    call search('.')
    normal! v
  else
    throw "Not on a parameter"
  endif

  let cnt = v:count <= 0 ? 1 : v:count

  while cnt > 0
    let cnt -= 1
    if 0 == searchpair('(', ',',')', 'W','lh#syntax#skip()')
      if lh#position#is_before(getpos('.'), saved_pos)
	" no "vi," when starting from the last parameter
	exe "normal! \<esc>"
	call setpos('.', saved_pos)
	throw (a:visual?'v':'').(a:inner?'i':'a').",: Cursor not on a parameter"
      else
	echomsg (a:visual?'v':'').(a:inner?'i':'a').",: No more parameters"
	" 999di, silently deletes everything till the end
	break
      endif
    endif
  endwhile
  " Don't include the last closing paren
  if a:inner == 1 || searchpair('(',',',')','n','lh#syntax#skip()') <= 0
    call search('.','b')
  endif
endfunction


" Private Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
