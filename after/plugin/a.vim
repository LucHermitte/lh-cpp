" Copyright (c) 1998-2006
" Michael Sharpe <feline@irendi.com>
"
" We grant permission to use, copy modify, distribute, and sell this
" software for any purpose without fee, provided that the above copyright
" notice and this text are not removed. We make no guarantee about the
" suitability of this software for any purpose and we are not liable
" for any damages resulting from its use. Further, we are under no
" obligation to maintain or extend this software. It is provided on an
" "as is" basis without any expressed or implied warranty.

" Directory & regex enhancements added by Bindu Wavell who is well known on
" vim.sf.net
"
" Patch for spaces in files/directories from Nathan Stien (also reported by
" Soeren Sonnenburg)

" 24th Jan 2008: Non official patches by Luc Hermitte
" 21st Apr 2010: Other non official patches by Luc Hermitte
"                -> introduces dependendy to autoplugin/lh/path.vim
" 02nd Apr 2012: dynamic options through lh-dev

" Do not load a.vim if is has already been loaded.
if &cp || (exists("loaded_alternateFile")
      \ && !exists('g:force_reload_a'))
    finish
endif
if (v:progname == "ex")
   finish
endif
let loaded_alternateFile = 1

let alternateExtensionsDict = {}

" setup the default set of alternate extensions. The user can override in thier
" .vimrc if the defaults are not suitable. To override in a .vimrc simply set a
" g:alternateExtensions_<EXT> variable to a comma separated list of alternates,
" where <EXT> is the extension to map.
" E.g. let g:alternateExtensions_CPP = "inc,h,H,HPP,hpp"
"      let g:alternateExtensions_{'aspx.cs'} = "aspx"


" This variable will be increased when an extension with greater number of dots
" is added by the SetAlternateExtensionMapping call.
let s:maxDotsInExtension = 1

" Function : SetAlternateExtensionMapping (PRIVATE)
" Purpose  : simple helper function to set the default alternate extension
"            mappings.
" Args     : extension -- the extension to map
"            alternates -- comma separated list of alternates extensions
" Returns  : nothing
" Author   : Michael Sharpe <feline@irendi.com>
function! <SID>SetAlternateExtensionMapping(extension, alternates)
   let g:alternateExtensionsDict[a:extension] = a:alternates
   let dotsNumber = strlen(substitute(a:extension, "[^.]", "", "g"))
   if s:maxDotsInExtension < dotsNumber
     let s:maxDotsInExtension = dotsNumber
   endif
endfunction


" Function : AddAlternateExtensionMapping (PRIVATE)
" Purpose  : simple helper function to add the default alternate extension
"            mappings.
" Args     : extension -- the extension to map
"            alternates -- comma separated list of alternates extensions
" Returns  : nothing
" Author   : Luc Hermitte <hermite {at} free {dot} fr>
function! AddAlternateExtensionMapping(extension, alternates)
   if !has_key(g:alternateExtensionsDict, a:extension)
      return s:SetAlternateExtensionMapping(a:extension, a:alternates)
   endif
   let new_alternates = split(a:alternates, ',')
   let know_alternates = split(g:alternateExtensionsDict[a:extension], ',')
   for a in new_alternates
      if match(know_alternates, a) == -1
         let know_alternates += [a]
      endif
   endfor
   let g:alternateExtensionsDict[a:extension] = join(know_alternates, ',')
   let dotsNumber = strlen(substitute(a:extension, "[^.]", "", "g"))
   if s:maxDotsInExtension < dotsNumber
     let s:maxDotsInExtension = dotsNumber
   endif
endfunction


" Add all the default extensions
" Mappings for C and C++
call <SID>SetAlternateExtensionMapping('h',"c,cpp,cxx,cc,CC")
call <SID>SetAlternateExtensionMapping('H',"C,CPP,CXX,CC")
call <SID>SetAlternateExtensionMapping('hpp',"cpp,c")
call <SID>SetAlternateExtensionMapping('HPP',"CPP,C")
call <SID>SetAlternateExtensionMapping('c',"h")
call <SID>SetAlternateExtensionMapping('C',"H")
call <SID>SetAlternateExtensionMapping('cpp',"h,hpp")
call <SID>SetAlternateExtensionMapping('CPP',"H,HPP")
call <SID>SetAlternateExtensionMapping('cc',"h")
call <SID>SetAlternateExtensionMapping('CC',"H,h")
call <SID>SetAlternateExtensionMapping('cxx',"h")
call <SID>SetAlternateExtensionMapping('CXX',"H")
" Mappings for PSL7
call <SID>SetAlternateExtensionMapping('psl',"ph")
call <SID>SetAlternateExtensionMapping('ph',"psl")
" Mappings for ADA
call <SID>SetAlternateExtensionMapping('adb',"ads")
call <SID>SetAlternateExtensionMapping('ads',"adb")
" Mappings for lex and yacc files
call <SID>SetAlternateExtensionMapping('l',"y,yacc,ypp")
call <SID>SetAlternateExtensionMapping('lex',"yacc,y,ypp")
call <SID>SetAlternateExtensionMapping('lpp',"ypp,y,yacc")
call <SID>SetAlternateExtensionMapping('y',"l,lex,lpp")
call <SID>SetAlternateExtensionMapping('yacc',"lex,l,lpp")
call <SID>SetAlternateExtensionMapping('ypp',"lpp,l,lex")
" Mappings for OCaml
call <SID>SetAlternateExtensionMapping('ml',"mli")
call <SID>SetAlternateExtensionMapping('mli',"ml")
" ASP stuff
call <SID>SetAlternateExtensionMapping('aspx.cs', 'aspx')
call <SID>SetAlternateExtensionMapping('aspx.vb', 'aspx')
call <SID>SetAlternateExtensionMapping('aspx', 'aspx.cs,aspx.vb')

" Setup default search path, unless the user has specified
" a path in their [._]vimrc. 
let s:alternateSearchPath_default = 'sfr:../source,sfr:../src,sfr:../include,sfr:../inc'
if (!exists('g:alternateSearchPath'))
  let g:alternateSearchPath = s:alternateSearchPath_default
endif
function! s:alternateSearchPath()
  return lh#dev#option#get('alternateSearchPath', &ft, s:alternateSearchPath_default)
endfunction

" If this variable is true then a.vim will not alternate to a file/buffer which
" does not exist. E.g while editing a.c and the :A will not swtich to a.h
" unless it exists.
if (!exists('g:alternateNoDefaultAlternate'))
   " by default a.vim will alternate to a file which does not exist
   let g:alternateNoDefaultAlternate = 0
endif

" If this variable is true then a.vim will convert the alternate filename to a
" filename relative to the current working directory.
" Feature by Nathan Huizinga
if (!exists('g:alternateRelativeFiles'))                                        
   " by default a.vim will not convert the filename to one relative to the
   " current working directory
   let g:alternateRelativeFiles = 0
endif


" Function : GetNthItemFromList (PRIVATE)
" Purpose  : Support reading items from a comma seperated list
"            Used to iterate all the extensions in an extension spec
"            Used to iterate all path prefixes
" Args     : list -- the list (extension spec, file paths) to iterate
"            n -- the extension to get
" Returns  : the nth item (extension, path) from the list (extension 
"            spec), or "" for failure
" Author   : Michael Sharpe <feline@irendi.com>
" History  : Renamed from GetNthExtensionFromSpec to GetNthItemFromList
"            to reflect a more generic use of this function. -- Bindu
function! <SID>GetNthItemFromList(list, n) 
   let itemStart = 0
   let itemEnd = -1
   let pos = 0
   let item = ""
   let i = 0
   while (i != a:n)
      let itemStart = itemEnd + 1
      let itemEnd = match(a:list, ",", itemStart)
      let i += 1
      if (itemEnd == -1)
         if (i == a:n)
            let itemEnd = strlen(a:list)
         endif
         break
      endif
   endwhile 
   if (itemEnd != -1) 
      let item = strpart(a:list, itemStart, itemEnd - itemStart)
   endif
   return item 
endfunction

" Function : ExpandAlternatePath (PRIVATE)
" Purpose  : Expand path info.  A path with a prefix of "wdr:" will be 
"            treated as relative to the working directory (i.e. the 
"            directory where vim was started.) A path prefix of "abs:" will 
"            be treated as absolute. No prefix or "sfr:" will result in the 
"            path being treated as relative to the source file (see sfPath 
"            argument). 
"
"            A prefix of "reg:" will treat the pathSpec as a regular
"            expression substitution that is applied to the source file 
"            path. The format is:
"
"              reg:<sep><pattern><sep><subst><sep><flag><sep>
"          
"            <sep> seperator character, we often use one of [/|%#] 
"            <pattern> is what you are looking for
"            <subst> is the output pattern
"            <flag> can be g for global replace or empty
"
"            EXAMPLE: 'reg:/inc/src/g/' will replace every instance 
"            of 'inc' with 'src' in the source file path. It is possible
"            to use match variables so you could do something like:
"            'reg:|src/\([^/]*\)|inc/\1||' (see 'help :substitute', 
"            'help pattern' and 'help sub-replace-special' for more details
"
"            NOTE: a.vim uses ',' (comma) internally so DON'T use it
"            in your regular expressions or other pathSpecs unless you update 
"            the rest of the a.vim code to use some other seperator.
"
" Args     : pathSpec -- path component (or substitution patterns)
"            sfPath -- source file path
" Returns  : a path that can be used by AlternateFile()
" Author   : Bindu Wavell <bindu@wavell.net>
function! <SID>ExpandAlternatePath(pathSpec, sfPath) 
   let prfx = strpart(a:pathSpec, 0, 4)
   if (prfx == "wdr:" || prfx == "abs:")
      let path = strpart(a:pathSpec, 4)
   elseif (prfx == "reg:")
      let re = strpart(a:pathSpec, 4)
      let sep = strpart(re, 0, 1)
      let patend = match(re, sep, 1)
      let pat = strpart(re, 1, patend - 1)
      let subend = match(re, sep, patend + 1)
      let sub = strpart(re, patend+1, subend - patend - 1)
      let flag = strpart(re, strlen(re) - 2)
      if (flag == sep)
        let flag = ''
      endif
      if a:sfPath =~ pat
	let path = substitute(a:sfPath, pat, sub, flag)
      else
	" LH, 24th Jan 2008: pattern not found => with "reg:" is rejected
	let path = ''
      endif
      "call confirm('PAT: [' . pat . '] SUB: [' . sub . ']')
      "call confirm(a:sfPath . ' => ' . path)
   else
      let path = a:pathSpec
      if (prfx == "sfr:")
         let path = strpart(path, 4)
      endif
      let path = a:sfPath . "/" . path
   endif
   return path
endfunction

" Function : FindFileInSearchPath (PRIVATE)
" Purpose  : Searches for a file in the search path list
" Args     : filename -- name of the file to search for
"            pathList -- the path list to search
"            relPathBase -- the path which relative paths are expanded from
" Returns  : An expanded filename if found, the empty string otherwise
" Author   : Michael Sharpe (feline@irendi.com)
" History  : inline code written by Bindu Wavell originally
function! <SID>FindFileInSearchPath(fileName, pathList, relPathBase)
   let filepath = ""
   let m = 1
   let pathListLen = strlen(a:pathList)
   if (pathListLen > 0)
      while (1)
         let pathSpec = <SID>GetNthItemFromList(a:pathList, m) 
         if (pathSpec != "")
            let path = <SID>ExpandAlternatePath(pathSpec, a:relPathBase)
            let fullname = path . "/" . a:fileName
            let foundMatch = <SID>BufferOrFileExists(fullname)
            if (foundMatch)
               let filepath = fullname
               break
            endif
         else
            break
         endif
         let m += 1
      endwhile
   endif
   return filepath
endfunction

" Function : FindFileInSearchPathEx (PRIVATE)
" Purpose  : Searches for a file in the search path list
" Args     : filename -- name of the file to search for
"            pathList -- the path list to search
"            relPathBase -- the path which relative paths are expanded from
"            count -- find the count'th occurence of the file on the path
" Returns  : An expanded filename if found, the empty string otherwise
" Author   : Michael Sharpe (feline@irendi.com)
" History  : Based on <SID>FindFileInSearchPath() but with extensions
function! <SID>FindFileInSearchPathEx(fileName, pathList, relPathBase, count)
   let filepath = ""
   let m = 1
   let spath = ""
   let pathListLen = strlen(a:pathList)
   if (pathListLen > 0)
      while (1)
         let pathSpec = <SID>GetNthItemFromList(a:pathList, m) 
         if (pathSpec != "")
            let path = <SID>ExpandAlternatePath(pathSpec, a:relPathBase)
            if (spath != "")
               let spath .= ','
            endif
            let spath .= path
         else
            break
         endif
         let m += 1
      endwhile
   endif

   if (&path != "")
      if (spath != "")
         let spath .= ','
      endif
      let spath .= &path
   endif

   let filepath = findfile(a:fileName, spath, a:count)
   return filepath
endfunction

" Function : EnumerateFilesByExtension (PRIVATE)
" Purpose  : enumerates all files by a particular list of alternate extensions.
" Args     : path -- path of a file (not including the file)
"            baseName -- base name of the file to be expanded
"            extension -- extension whose alternates are to be enumerated
" Returns  : comma separated list of files with extensions
" Author   : Michael Sharpe <feline@irendi.com>
function! EnumerateFilesByExtension(path, baseName, extension)
   let enumeration = ""
   let extSpec = ""
   let v:errmsg = ""
   silent! echo g:alternateExtensions_{a:extension}
   if (v:errmsg == "")
      let extSpec = g:alternateExtensions_{a:extension}
   endif
   if (extSpec == "")
      if (has_key(g:alternateExtensionsDict, a:extension))
         let extSpec = g:alternateExtensionsDict[a:extension]
      endif
   endif
   if (extSpec != "") 
      let n = 1
      let done = 0
      while (!done)
         let ext = <SID>GetNthItemFromList(extSpec, n)
         if (ext != "")
            if (a:path != "")
               let newFilename = a:path . "/" . a:baseName . "." . ext
            else
               let newFilename =  a:baseName . "." . ext
            endif
            if (enumeration == "")
               let enumeration = newFilename
            else
               let enumeration .= "," . newFilename
            endif
         else
            let done = 1
         endif
         let n += 1
      endwhile
   endif
   return enumeration
endfunction

" Function : EnumerateFilesByExtensionInPath (PRIVATE)
" Purpose  : enumerates all files by expanding the path list and the extension
"            list.
" Args     : baseName -- base name of the file
"            extension -- extension whose alternates are to be enumerated
"            pathList -- the list of paths to enumerate
"            relPath -- the path of the current file for expansion of relative
"                       paths in the path list.
" Returns  : A comma separated list of paths with extensions
" Author   : Michael Sharpe <feline@irendi.com>
function! EnumerateFilesByExtensionInPath(baseName, extension, pathList, relPathBase)
   let enumeration = ""
   let filepath = ""
   let m = 1
   let pathListLen = strlen(a:pathList)
   if (pathListLen > 0)
      while (1)
         let pathSpec = <SID>GetNthItemFromList(a:pathList, m) 
         if (pathSpec != "")
            let path = <SID>ExpandAlternatePath(pathSpec, a:relPathBase)
	    "LH, 24th Jan 2008: test ExpandAlternatePath result
	    if path != ""
	      let pe = EnumerateFilesByExtension(path, a:baseName, a:extension)
	      if (enumeration == "")
		let enumeration = pe
	      else
		let enumeration .= "," . pe
	      endif
	    endif
         else
            break
         endif
         let m += 1
      endwhile
   endif
   return enumeration
endfunction

" Function : DetermineExtension (PRIVATE)
" Purpose  : Determines the extension of a filename based on the register
"            alternate extension. This allow extension which contain dots to 
"            be considered. E.g. foo.aspx.cs to foo.aspx where an alternate
"            exists for the aspx.cs extension. Note that this will only accept
"            extensions which contain less than 5 dots. This is only
"            implemented in this manner for simplicity...it is doubtful that 
"            this will be a restriction in non-contrived situations.
" Args     : The path to the file to find the extension in
" Returns  : The matched extension if any
" Author   : Michael Sharpe (feline@irendi.com)
" History  : idea from Tom-Erik Duestad
" Notes    : there is some magic occuring here. The exists() function does not
"            work well when the curly brace variable has dots in it. And why
"            should it, dots are not valid in variable names. But the exists
"            function is wierd too. Lets say foo_c does exist. Then
"            exists("foo_c.e.f") will be true...even though the variable does 
"            not exist. However the curly brace variables do work when the
"            variable has dots in it. E.g foo_{'c'} is different from 
"            foo_{'c.d.e'}...and foo_{'c'} is identical to foo_c and
"            foo_{'c.d.e'} is identical to foo_c.d.e right? Yes in the current
"            implementation of vim. To trick vim to test for existence of such
"            variables echo the curly brace variable and look for an error 
"            message.
function! DetermineExtension(path) 
  let mods = ":t"
  let i = 0
  while i <= s:maxDotsInExtension
    let mods .= ":e"
    let extension = fnamemodify(a:path, mods)
    if (has_key(g:alternateExtensionsDict, extension))
       return extension
    endif
    let v:errmsg = ""
    silent! echo g:alternateExtensions_{extension}
    if (v:errmsg == "")
      return extension
    endif
    let i += 1
  endwhile
  return ""
endfunction

"source $HOME/vimscripts/plugin/Decho.vim

" Function : AlternateFile (PUBLIC)
" Purpose  : Opens a new buffer by looking at the extension of the current
"            buffer and finding the corresponding file. E.g. foo.c <--> foo.h
" Args     : accepts one argument. If present it used the argument as the new
"            extension.
" Returns  : nothing
" Author   : Michael Sharpe <feline@irendi.com>
" History  : + When an alternate can't be found in the same directory as the
"              source file, a search path will be traversed looking for the
"              alternates.
"            + Moved some code into a separate function, minor optimization
"            + rework to favor files in memory based on complete enumeration of
"              all files extensions and paths
function! AlternateFile(splitWindow, ...)
  let extension   = DetermineExtension(expand("%:p"))
  let baseName    = substitute(expand("%:t"), "\." . extension . '$', "", "")
  let currentPath = expand("%:p:h")

"Decho "extension=".extension
"Decho "baseName=".baseName
"Decho "currentPath=".currentPath

  if (a:0 != 0)
     let newFullname = currentPath . "/" .  baseName . "." . a:1
     call <SID>FindOrCreateBuffer(newFullname, a:splitWindow, 0)
  else
     let allfiles = ""
     if (extension != "")
        let allfiles1 = EnumerateFilesByExtension(currentPath, baseName, extension)
        let allfiles2 = EnumerateFilesByExtensionInPath(baseName, extension, s:alternateSearchPath(), currentPath)

"Decho "allfiles1=".allfiles1
"Decho "allfiles2=".allfiles2

        if (allfiles1 != "")
           if (allfiles2 != "")
              let allfiles = allfiles1 . ',' . allfiles2
           else
              let allfiles = allfiles1
           endif
        else 
           let allfiles = allfiles2
        endif
     endif

     if (allfiles != "") 
        let bestFile = ""
        let bestScore = 0
        let score = 0
        let n = 1
         
        let onefile = <SID>GetNthItemFromList(allfiles, n)
        let bestFile = onefile
        while (onefile != "" && score < 2)
           let score = <SID>BufferOrFileExists(onefile)
           if (score > bestScore)
              let bestScore = score
              let bestFile = onefile
           endif
           let n += 1
           let onefile = <SID>GetNthItemFromList(allfiles, n)
        endwhile

        if (bestScore == 0 && g:alternateNoDefaultAlternate == 1)
           echo "No existing alternate available"
        else
           call <SID>FindOrCreateBuffer(bestFile, a:splitWindow, 1)
           let b:AlternateAllFiles = allfiles
        endif
     else
        echo "No alternate file/buffer available"
     endif
   endif
endfunction

" Function : AlternateOpenFileUnderCursor (PUBLIC)
" Purpose  : Opens file under the cursor
" Args     : splitWindow -- indicates how to open the file
" Returns  : Nothing
" Author   : Michael Sharpe (feline@irendi.com) www.irendi.com
function! AlternateOpenFileUnderCursor(splitWindow,...)
   let cursorFile = (a:0 > 0) ? a:1 : expand("<cfile>") 
   let currentPath = expand("%:p:h")
   let openCount = 1

   let fileName = <SID>FindFileInSearchPathEx(cursorFile, s:alternateSearchPath(), currentPath, openCount)
   if (fileName != "")
      call <SID>FindOrCreateBuffer(fileName, a:splitWindow, 1)
      let b:openCount = openCount
      let b:cursorFile = cursorFile
      let b:currentPath = currentPath
   else
      echo "Can't find file"
   endif
endfunction

" Function : AlternateOpenNextFile (PUBLIC)
" Purpose  : Opens the next file corresponding to the search which found the 
"            current file
" Args     : bang -- indicates what to do if the current file has not been 
"                    saved
" Returns  : nothing
" Author   : Michael Sharpe (feline@irendi.com) www.irendi.com
function! AlternateOpenNextFile(bang)
   let cursorFile = ""
   if (exists("b:cursorFile"))
      let cursorFile = b:cursorFile
   endif

   let currentPath = ""
   if (exists("b:currentPath"))
      let currentPath = b:currentPath
   endif

   let openCount = 0
   if (exists("b:openCount"))
      let openCount = b:openCount + 1
   endif

   if (cursorFile != ""  && currentPath != ""  && openCount != 0)
      let fileName = <SID>FindFileInSearchPathEx(cursorFile, s:alternateSearchPath(), currentPath, openCount)
      if (fileName != "")
         call <SID>FindOrCreateBuffer(fileName, "n".a:bang, 0)
         let b:openCount = openCount
         let b:cursorFile = cursorFile
         let b:currentPath = currentPath
      else 
         let fileName = <SID>FindFileInSearchPathEx(cursorFile, s:alternateSearchPath(), currentPath, 1)
         if (fileName != "")
            call <SID>FindOrCreateBuffer(fileName, "n".a:bang, 0)
            let b:openCount = 1
            let b:cursorFile = cursorFile
            let b:currentPath = currentPath
         else
            echo "Can't find next file"
         endif
      endif
   endif
endfunction

comm! -nargs=? -bang IH call AlternateOpenFileUnderCursor("n<bang>", <f-args>)
comm! -nargs=? -bang IHS call AlternateOpenFileUnderCursor("h<bang>", <f-args>)
comm! -nargs=? -bang IHV call AlternateOpenFileUnderCursor("v<bang>", <f-args>)
comm! -nargs=? -bang IHT call AlternateOpenFileUnderCursor("t<bang>", <f-args>)
comm! -nargs=? -bang IHN call AlternateOpenNextFile("<bang>")
imap <Leader>ih <ESC>:IHS<CR>
nmap <Leader>ih :IHS<CR>
imap <Leader>is <ESC>:IHS<CR>:A<CR>
nmap <Leader>is :IHS<CR>:A<CR>
imap <Leader>ihn <ESC>:IHN<CR>
nmap <Leader>ihn :IHN<CR>

"function! <SID>PrintList(theList) 
"   let n = 1
"   let oneFile = <SID>GetNthItemFromList(a:theList, n)
"   while (oneFile != "")
"      let n += 1
"      let oneFile = <SID>GetNthItemFromList(a:theList, n)
"   endwhile
"endfunction

" Function : NextAlternate (PUBLIC)
" Purpose  : Used to cycle through any other alternate file which existed on
"            the search path.
" Args     : bang (IN) - used to implement the AN vs AN! functionality
" Returns  : nothing
" Author   : Michael Sharpe <feline@irendi.com>
function! NextAlternate(bang)
   if (exists('b:AlternateAllFiles'))
      let currentFile = expand("%")
      let n = 1
      let onefile = <SID>GetNthItemFromList(b:AlternateAllFiles, n)
      while (onefile != "" && !<SID>EqualFilePaths(fnamemodify(onefile,":p"), fnamemodify(currentFile,":p")))
         let n += 1
         let onefile = <SID>GetNthItemFromList(b:AlternateAllFiles, n)
      endwhile

      if (onefile != "")
         let stop = n
         let n += 1
         let foundAlternate = 0
         let nextAlternate = ""
         while (n != stop)
            let nextAlternate = <SID>GetNthItemFromList(b:AlternateAllFiles, n)
            if (nextAlternate == "")
               let n = 1
               continue
            endif
            let n += 1
            if (<SID>EqualFilePaths(fnamemodify(nextAlternate, ":p"), fnamemodify(currentFile, ":p")))
                continue
            endif
            if (filereadable(nextAlternate))
                " on cygwin filereadable("foo.H") returns true if "foo.h" exists
               if (has("unix") && $WINDIR != "" && fnamemodify(nextAlternate, ":p") ==? fnamemodify(currentFile, ":p")) 
                  continue
               endif
               let foundAlternate = 1
               break
            endif
         endwhile
         if (foundAlternate == 1)
            let s:AlternateAllFiles = b:AlternateAllFiles
            "silent! execute ":e".a:bang." " . nextAlternate
            call <SID>FindOrCreateBuffer(nextAlternate, "n".a:bang, 0)
            let b:AlternateAllFiles = s:AlternateAllFiles
         else 
            echo "Only this alternate file exists"
         endif
      else 
         echo "Could not find current file in alternates list"
      endif
   else 
      echo "No other alternate files exist"
   endif
endfunction

comm! -nargs=? -bang A call AlternateFile("n<bang>", <f-args>)
comm! -nargs=? -bang AS call AlternateFile("h<bang>", <f-args>)
comm! -nargs=? -bang AV call AlternateFile("v<bang>", <f-args>)
comm! -nargs=? -bang AT call AlternateFile("t<bang>", <f-args>)
comm! -nargs=? -bang AN call NextAlternate("<bang>")

" Function : BufferOrFileExists (PRIVATE)
" Purpose  : determines if a buffer or a readable file exists
" Args     : fileName (IN) - name of the file to check
" Returns  : 2 if it exists in memory, 1 if it exists, 0 otherwise
" Author   : Michael Sharpe <feline@irendi.com>
" History  : Updated code to handle buffernames using just the
"            filename and not the path.
function! <SID>BufferOrFileExists(fileName)
   let result = 0

   let lastBuffer = bufnr("$")
   let i = 1
   while i <= lastBuffer
     if <SID>EqualFilePaths(expand("#".i.":p"), a:fileName)
       let result = 2
       break
     endif
     let i += 1
   endwhile

   if (!result) 
      let bufName = fnamemodify(a:fileName,":t")
      let memBufName = bufname(bufName)
      if (memBufName != "")
         let memBufBasename = fnamemodify(memBufName, ":t")
         if (bufName == memBufBasename)
            let result = 2
         endif
      endif

      if (!result)
         let result  = bufexists(bufName) || bufexists(a:fileName) || filereadable(a:fileName)
      endif
   endif

   if (!result)
      let result = filereadable(a:fileName)
   endif
   return result
endfunction

" Function : FindOrCreateBuffer (PRIVATE)
" Purpose  : searches the buffer list (:ls) for the specified filename. If
"            found, checks the window list for the buffer. If the buffer is in
"            an already open window, it switches to the window. If the buffer
"            was not in a window, it switches to that buffer. If the buffer did
"            not exist, it creates it.
" Args     : filename (IN) -- the name of the file
"            doSplit (IN) -- indicates whether the window should be split
"                            ("v", "h", "n", "v!", "h!", "n!", "t", "t!") 
"            findSimilar (IN) -- indicate weather existing buffers should be
"                                prefered
" Returns  : nothing
" Author   : Michael Sharpe <feline@irendi.com>
" History  : + bufname() was not working very well with the possibly strange
"            paths that can abound with the search path so updated this
"            slightly.  -- Bindu
"            + updated window switching code to make it more efficient -- Bindu
"            Allow ! to be applied to buffer/split/editing commands for more
"            vim/vi like consistency
"            + implemented fix from Matt Perry
function! <SID>FindOrCreateBuffer(fileName, doSplit, findSimilar)
  " Check to see if the buffer is already open before re-opening it.
  let FILENAME = escape(a:fileName, ' ')
  let bufNr = -1
  let lastBuffer = bufnr("$")
  let i = 1
  if (a:findSimilar) 
     while i <= lastBuffer
       if <SID>EqualFilePaths(expand("#".i.":p"), a:fileName)
         let bufNr = i
         break
       endif
       let i += 1
     endwhile

     if (bufNr == -1)
        let bufName = bufname(a:fileName)
        let bufFilename = fnamemodify(a:fileName,":t")

        if (bufName == "")
           let bufName = bufname(bufFilename)
        endif

        if (bufName != "")
           let tail = fnamemodify(bufName, ":t")
           if (tail != bufFilename)
              let bufName = ""
           endif
        endif
        if (bufName != "")
           let bufNr = bufnr(bufName)
           let FILENAME = bufName
        endif
     endif
  endif

  if (g:alternateRelativeFiles == 1)                                            
        let FILENAME = fnamemodify(FILENAME, ":p:.")
  endif

  let splitType = a:doSplit[0]
  let bang = a:doSplit[1]
  " LH, 21st Apr 2010 -> simplify the filename to be sure to use the best
  " relative path from getcwd()
  let FILENAME = lh#path#simplify(FILENAME)

  if (bufNr == -1)
     " Buffer did not exist....create it
     let v:errmsg=""
     if (splitType == "h")
        silent! execute ":split".bang." " . FILENAME
     elseif (splitType == "v")
        silent! execute ":vsplit".bang." " . FILENAME
     elseif (splitType == "t")
        silent! execute ":tab split".bang." " . FILENAME
     else
        silent! execute ":e".bang." " . FILENAME
     endif
     if (v:errmsg != "")
        echo v:errmsg
     endif
  else

     " Find the correct tab corresponding to the existing buffer
     let tabNr = -1
     " iterate tab pages
     for i in range(tabpagenr('$'))
        " get the list of buffers in the tab
        let tabList =  tabpagebuflist(i + 1)
        let idx = 0
        " iterate each buffer in the list
        while idx < len(tabList)
           " if it matches the buffer we are looking for...
           if (tabList[idx] == bufNr)
              " ... save the number
              let tabNr = i + 1
              break
           endif
           let idx += 1
        endwhile
        if (tabNr != -1)
           break
        endif
     endfor
     " switch the the tab containing the buffer
     if (tabNr != -1)
        execute "tabn ".tabNr
     endif

     " Buffer was already open......check to see if it is in a window
     let bufWindow = bufwinnr(bufNr)
     if (bufWindow == -1) 
        " Buffer was not in a window so open one
        let v:errmsg=""
        if (splitType == "h")
           silent! execute ":sbuffer".bang." " . FILENAME
        elseif (splitType == "v")
           silent! execute ":vert sbuffer " . FILENAME
        elseif (splitType == "t")
           silent! execute ":tab sbuffer " . FILENAME
        else
           silent! execute ":buffer".bang." " . FILENAME
        endif
        if (v:errmsg != "")
           echo v:errmsg
        endif
     else
        " Buffer is already in a window so switch to the window
        execute bufWindow."wincmd w"
        if (bufWindow != winnr()) 
           " something wierd happened...open the buffer
           let v:errmsg=""
           if (splitType == "h")
              silent! execute ":split".bang." " . FILENAME
           elseif (splitType == "v")
              silent! execute ":vsplit".bang." " . FILENAME
           elseif (splitType == "t")
              silent! execute ":tab split".bang." " . FILENAME
           else
              silent! execute ":e".bang." " . FILENAME
           endif
           if (v:errmsg != "")
              echo v:errmsg
           endif
        endif
     endif
  endif
endfunction

" Function : EqualFilePaths (PRIVATE)
" Purpose  : Compares two paths. Do simple string comparison anywhere but on
"            Windows. On Windows take into account that file paths could differ
"            in usage of separators and the fact that case does not matter.
"            "c:\WINDOWS" is the same path as "c:/windows". has("win32unix") Vim
"            version does not count as one having Windows path rules.
" Args     : path1 (IN) -- first path
"            path2 (IN) -- second path
" Returns  : 1 if path1 is equal to path2, 0 otherwise.
" Author   : Ilya Bobir <ilya@po4ta.com>
function! <SID>EqualFilePaths(path1, path2)
  if has("win16") || has("win32") || has("win64") || has("win95")
    return substitute(a:path1, "\/", "\\", "g") ==? substitute(a:path2, "\/", "\\", "g")
  else
    return a:path1 == a:path2
  endif
endfunction

" LH addition, 13th Aug 2007, vim7 required
function! A_debug(func, ...)
  let Fn = function('s:'.a:func)
  let res = call(Fn, a:000)
  return res
endfunction

" vim:sw=3:
