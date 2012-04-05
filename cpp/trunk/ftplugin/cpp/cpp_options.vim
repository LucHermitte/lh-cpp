" ========================================================================
" $Id$
" File:		ftplugin/cpp/cpp_InsertAccessors.vim                  {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Last Change:	$Date$ (28th July 2003)
" Version:	2.0.0
"
"------------------------------------------------------------------------
" Description:	
"	Options for C & C++ editing.
"
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" 	Override these definitions in each C|C++ project.
" TODO: move these definitions to autoload/lh/cpp/option.vim as the approach
" used in this file is now deprecated
" }}}1
" ==========================================================================
if !exists("g:do_load_cpp_options") | finish | endif
unlet g:do_load_cpp_options
"
exe 'command! -nargs=0 CppEditOptions :sp '.expand('<sfile>:p')
exe 'command! -nargs=0 CppReloadOptions :so '.expand('<sfile>:p')
" ====================================================================
" Preferences for the names of classes' attributes and their accessors {{{
" ====================================================================
"
let g:accessorCap  = -1
" g:accessorCap = -1 (lowcase), 0 (no change), 1 (upcase)

let g:accessor_comment_attribute = '/** %a ... */'
let g:accessor_comment_get = '/** Get accessor to %a */'
let g:accessor_comment_set = '/** Set accessor to %a */'
let g:accessor_comment_proxy_get = '/** Proxy-Get accessor to %a */'
let g:accessor_comment_proxy_set = '/** Proxy-Set accessor to %a */'
let g:accessor_comment_ref = '/** Ref. accessor to %a */'
let g:accessor_comment_proxy_ref = '/** Proxy-Ref. accessor to %a */'

" To use markers/placeholders, use Marker_Txt()
" let g:accessor_comment_get = Marker_Txt('/** Get accessor to %a */')

" Luc's Preferences:
let g:setPrefix  = 'set_'
let g:getPrefix  = 'get_'
let g:refPrefix  = 'ref_'
let g:dataPrefix = 'm_'
let g:dataSuffix = ''
let g:paramPrefix = ''
let g:paramSuffix = ''

""" Very Short Style:
""let g:setPrefix  = ''
""let g:getPrefix  = ''
""let g:refPrefix  = ''
""let g:dataPrefix = ''
""let g:dataSuffix = '_'
""let g:paramPrefix = ''
""let g:paramSuffix = ''
"
""" Herb Sutter's Style:
""let g:setPrefix  = 'Set'
""let g:getPrefix  = 'Get'
""let g:refPrefix  = 'Get'
""let g:dataPrefix = ''
""let g:dataSuffix = '_'
""let g:paramPrefix = ''
""let g:paramSuffix = ''
" }}}
" ====================================================================
" Preference regarding where accessors' definitions occur {{{
" ====================================================================
"
" Possible Values:
"   0: Near the prototype/definition (Java's way)
"   1: Within the inline section of the header/inline/current file
"   2: Within the implementation file (.cpp)
"   3: Use the pimpl idiom
let g:implPlace = 1
" }}}
" ====================================================================
" Preference regarding where inlines are written {{{
" ====================================================================
" Possible values:
"   0: In the inline section of the header/current file
"   1: In the inline section of a dedicated inline file
let g:inlinesPlace = 1

" Function used by Cpp_reachInlinePart()
function! Cpp_fileTypeRegardingOption()
  return g:inlinesPlace
endfunction
" }}}
" ====================================================================
" Preferences regarding what is shown in functions signatures {{{
" IE.: Should every element from the signature of a function be reminded along
" with the implementationof the function ?
"
" ShowVirtual = 0 -> '' ; 1 -> '/*virtual*/'
let g:cpp_ShowVirtual		= 1

" ShowStatic  = 0 -> '' ; 1 -> '/*static*/'
let g:cpp_ShowStatic 		= 1

" ShowExplicit= 0 -> '' ; 1 -> '/*explicit*/'
let g:cpp_ShowExplicit 		= 1

" ShowDefaultParam = 0 -> '' ;
" 		     1 -> default value for params within comments ;
"		     2 -> within comment as well, but spaces are trimmed ;
"		     3 -> like 2, but the equal sign is not displayed.
let g:cpp_ShowDefaultParams	= 1
" }}}
" ====================================================================
" Preference regarding where functions definitions are written {{{
" ====================================================================
"
" Possible Values:
"   0: At the end of the file plus offset g:cpp_FunctionPosArg
"   1: Search for a specific pattern g:cpp_FunctionPosArg
"      Useful if you use template skeletons
"   2: Call a user specified function : g:cpp_FunctionPosArg
"      Beware! This is a (security) back door.
"   3: Store the value in a temporary variable ; to be used in conjunction
"      with :PASTEIMPL -- Robert Kelly IV's approach
let g:cpp_FunctionPosition = 2
if exists('g:cpp_FunctionPosArg') | unlet g:cpp_FunctionPosArg | endif

function! s:GroupPattern(group) " {{{
  " Yes the pattern is very, very complex.
  " It searches for "/*===[ groupname ]===*/\n/*=======*/" followed by :
  "   - either the end of the file
  "   - or a line not made of one and only one comment
  " Todo: Support "//" comments
  return '/\*=*\[ '.a:group.' \]=*\*/\_s*/\*=*\*/\zs'.
	\ '\%(\%$\|\_s\%(^/\*\%(\*[^/]\|[^*]\)*\*/\s*$\)\@!\)'
endfunction
" }}}

" Some default definitions of g:cpp_FunctionPosArg regarding the chosen value
" of g:cpp_FunctionPosition. Use them as examples for your code preferences.
if     g:cpp_FunctionPosition == 0 " {{{
  let g:cpp_FunctionPosArg = -1
  " }}}
elseif g:cpp_FunctionPosition == 1 " {{{
  " That one fit my own needs. Find your owns
  let g:cpp_FunctionPosArg = s:GroupPattern('«»')
  " }}}
elseif g:cpp_FunctionPosition == 2 " {{{
  let g:cpp_FunctionPosArg = 'Cpp_SearchForGroup'
  function! Cpp_SearchForGroup()
    " Cf cpp_BuildTemplate.vim::BLINE for groups definitions:
    "    /*=================*/ (80 characters)
    "    /*====[ title ]====*/
    "    /*=================*/
    " Todo: Move this function into cpp_BuildTemplate.vim
    let g = inputdialog('Which group do you want to search for ?')
    if "" == g | return -1
    else
      let s = search(s:GroupPattern(g))
      if 0 == s 
	echoerr "Can't find group [ ".g." ]!!!"
	return -1
      else      | return s
      endif
    endif
  endfunction
  " }}}
endif
  
" }}}
" ====================================================================
" File extensions {{{
" ====================================================================
function! Cpp_FileExtension4Inlines()
  return '.inl'
endfunction

function! Cpp_FileExtension4Implementation()
  return '.cpp'
endfunction
" }}}
" ====================================================================
" vim600: set fdm=marker:
