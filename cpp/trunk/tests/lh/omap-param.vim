" ======================================================================
" $Id$
" File:		tests/lh/omap-param.vim
" Maintainer:	Luc Hermitte <MAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Last Update:	$Date$
" Version:	1.1.0
"
"
" Author: Luc Hermitte
" Notes:
" * "i," can't be used to select several parameters with several uses of
" "i," ; use "a," instead (-> "va,a,a,"). This is because of simple letter
" parameters.
" However, "v2i," works perfectly.
" * Requires Vim 7+
" * The following should be resistant to &magic, and other mappings
" * select-mode is not parasited by this plugin
" ======================================================================

onoremap <silent> i, :<c-u>call <sid>SelectParam(1,0)<cr>
xnoremap <silent> i, :<c-u>call <sid>SelectParam(1,1)<cr><esc>gv
onoremap <silent> a, :<c-u>call <sid>SelectParam(0,0)<cr>
xnoremap <silent> a, :<c-u>call <sid>SelectParam(0,1)<cr><esc>gv

if 0
  call Un(Null,fun2(fun3(a,b,g(NULL))),t, titi, r  , zzz
  call Un(Null,fun2(fun3(a,b,g(NULL))),t, titi, r  , zzz)
endif

function! s:SelectParam(inner, visual)
  let saved_pos = getpos('.')
  if a:visual ==1 && s:CharAtMark("'>") =~ '[(,]'  
	\ && !s:SkipAtMark("'>")
    normal! gv
  elseif searchpair('(',',',')','bcW','s:Skip()') > 0 ||
	\ searchpair('(',',',')','bW','s:Skip()') > 0
    " Test necessary because 'c' flag and Skip() don't always work well together
    call search('.')
    normal! v
  else
    throw "Not on a parameter"
  endif

  let cnt = v:count <= 0 ? 1 : v:count

  while cnt > 0
    let cnt -= 1
    if 0 == searchpair('(', ',',')', 'W','s:Skip()')
      if s:IsBefore(getpos('.'), saved_pos)
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
  if a:inner == 1 || searchpair('(',',',')','n','s:Skip()') <= 0
    call search('.','b')
  endif
endfunction

function! s:CharAtMark(char)
  let c = getline(a:char)[col(a:char)-1]
  return c
endfunction

func! s:SkipAt(l,c)
  return synIDattr(synID(a:l, a:c, 0),'name') =~?
	\ 'string\|comment\|character\|doxygen'
endfun

func! s:Skip()
  return s:SkipAt(line('.'), col('.'))
endfun

func! s:SkipAtMark(mark)
  return s:SkipAt(line(a:mark), col(a:mark))
endfun

function! s:IsBefore(lhs_pos, rhs_pos)
  if a:lhs_pos[0] != a:rhs_pos[0]
    throw "Postions from incompatible buffers can't be ordered"
  endif
  "1 test lines
  "2 test cols
  let before 
	\ = (a:lhs_pos[1] == a:rhs_pos[1])
	\ ? (a:lhs_pos[2] < a:rhs_pos[2])
	\ : (a:lhs_pos[1] < a:rhs_pos[1])
  return before
endfunction

function! SelectParam(i,v)
  call s:SelectParam(a:i, a:v)
endfunction

" by A.Politz
"assert("cursor at or in front of opening paren")
func! FargsPos()
  let res = []
  let p0 = getpos('.')
  "find first paren
  if !search('(','Wc')
    return []
  endif
  call add(res,getpos('.'))
  "goto closing paren
  if searchpair('(','',')','W','Skip()') <= 0
    call setpos('.',p0)
    return []
  endif
  let end = getpos('.')
  "go back to opening paren
  call setpos('.',res[0])
  "search for ',' , while not at the closing paren
  while searchpair('(',',',')','W','Skip()') > 0 && getpos('.') != end
    call add(res,getpos('.'))
  endwhile
  call add( res , end)
  call setpos('.',p0)
  return res " = positions of '(' ',' ... ')'
endfun

finish

function! s:t(a, b, c, d e,, f  )
  «»
endfunction«»

fun(Null,fun2(fun3(a,b,g(NULL))), zzz)
