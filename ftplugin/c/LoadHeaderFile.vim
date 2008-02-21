" LoadHeaderFile
" Last Change: 29th july 2001 by Luc Hermitte
" -> Split lines and change indentation in order to fit within 80 cols
" -> Change the way the filename is extracted from the include line
" Maintainer: Garner Halloran (garner@havoc.gtf.org)

if !exists( "g:loaded_LoadHeaderFile" ) 
  ""finish 
""endif
  let g:loaded_LoadHeaderFile = 1

fun! LoadHeaderFile( arg, loadSource )
  if match( a:arg, "#include" ) >= 0
      " extract the file name
      let matchPattern = '\s*#include\s*\(<\|"\)\(.*\)\(>\|"\)\s*'
      let $filename = substitute( a:arg, matchPattern, '\2', 'g')

      if strlen($filename) != 0
	" if loadSource is 1, then replace .h with .cpp and load that file
	" instead
	if a:loadSource == 1
	  let $filename = substitute( $filename, '\V.h', ".cpp", "" )
	" if loadSource is 2, then replace .h with .c and load that file
	" instead
	elseif a:loadSource == 2
	  let $filename = substitute( $filename, '\V.h', ".c", "" )
	endif

	sfind $filename
	return
      endif
  endif
endfun


endif
