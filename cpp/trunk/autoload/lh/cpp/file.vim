"=============================================================================
" $Id$
" File:		file.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	«version»
" Created:	12th Feb 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	«description»
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------

function! lh#cpp#file#IncludedPaths()
  return lh#option#Get("cpp_included_paths", '.', 'bg')
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
    if len(l_matches) > 1
      call map(l_matches, 'Marker_Txt(v:val)')
    endif
    let inc_paths = lh#cpp#file#IncludedPaths()
    call map(l_matches, 'lh#path#StripStart(v:val, inc_paths)')
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
