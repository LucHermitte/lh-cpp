"=============================================================================
" $Id$
" File:		autoload/lh/cpp/file.vim                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	12th Feb 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	«description»
" 
"------------------------------------------------------------------------
" Installation:	
" 	drop into {rtp}/autoload/lh/cpp
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Functions {{{1
" # Debug {{{2
function! lh#cpp#file#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#file#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" # Public {{{2
function! lh#cpp#file#IncludedPaths()
  let paths = copy(lh#option#get("cpp_included_paths", [], 'bg'))
  call add(paths, '.')
  return paths
endfunction

function! s:ValidFile(filename)
  return filereadable(a:filename) || bufexists(a:filename)
endfunction

function! lh#cpp#file#HeaderName(file)
  if exists("*EnumerateFilesByExtension") " From a.vim
    let extension   = DetermineExtension(fnamemodify(a:file, ":p"))
    let baseName    = substitute(fnamemodify(a:file, ":t"), "\." . extension . '$', "", "")
    let currentPath = fnamemodify(a:file, ":p:h")
    let allfiles1 = EnumerateFilesByExtension(currentPath, baseName, extension)
    let allfiles2 = EnumerateFilesByExtensionInPath(baseName, extension, g:alternateSearchPath, currentPath)
    let comma = strlen(allfiles1) && strlen(allfiles2)
    let allfiles = allfiles1 . (comma ? ',' : '') . allfiles2

    let l_allfiles = split(allfiles, ',')
    let l_matches  = filter(l_allfiles, 'filereadable(v:val) || bufexists(v:val)')
    call map(l_matches, 'lh#path#simplify(v:val)')
    let l_matches = lh#list#unique_sort(l_matches)
    let inc_paths = lh#cpp#file#IncludedPaths()
    call map(l_matches, 'lh#path#strip_start(v:val, inc_paths)')
    if len(l_matches) > 1
      call map(l_matches, 'Marker_Txt(v:val)')
    endif
    return join(l_matches,'')
  else " a.vim is not installed
    let base = fnamemodify(a:file, ":r")
    if      s:ValidFile(base.'.h')   | return base.'h'
    elseif  s:ValidFile(base.'.hh')  | return base.'hh'
    elseif  s:ValidFile(base.'.hpp') | return base.'hpp'
    endif
  endif
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
