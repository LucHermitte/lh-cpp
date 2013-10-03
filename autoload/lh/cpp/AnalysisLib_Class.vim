" ========================================================================
" $Id$
" File:		autoload/lh/cpp/AnalysisLib_Class.vim                 {{{1
" Author:	Luc Hermitte <MAIL:hermitte at free.fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
" Last Update:	$Date$ (13th Feb 2008)
"------------------------------------------------------------------------
" Description:	
" 	Library C++ ftplugin.
" 	It provides functions used by other C++ ftplugins.
" 	The theme of this library is the analysis of C++ scopes.
"
" Defines: {{{2
" (*) Function: lh#cpp#AnalysisLib_Class#CurrentScope(lineNo, scope_type)
"     Returns the scope (class name or namespace name) at line lineNo.
"     scope_type can value: "any", "class" or "namespace".
" (*) Function: lh#cpp#AnalysisLib_Class#SearchClassDefinition(lineNo)
"     Returns the class name of any member at line lineNo -- could be of the
"     form: "A::B::C" for nested classes.
"     Note: Outside class-scope, an empty string is returned
"     Note: Classes must be correctly defined: don't forget the ';' after the
"     '}'
" (*) Function lh#cpp#AnalysisLib_Class#BaseClasses(lineNo)
"     Return the list of the direct base classes of the class around lineNo.
"     form: "+a_public_class, #a_protected_class, -a_private_class"
" }}}2
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" Dependencies:	VIM 7.0+

" History:	{{{2
"	31st May 2012
"	(*) v2.0.0 , License GPLv3 w/ extension
" 	26th Aug 2011
" 	(*) list of imported namespaces lh#cpp#AnalysisLib_Class#used_namespaces
" 	31st May 2010
" 	(*) many generic functions move to lh#dev#class#
" 	23rd Apr 2008
" 	(*) #Ancestors() return the list of base classes (topologicaly sorted)
" 	13th Feb 2008
" 	(*) new option [bg]:cpp_defines_to_ignore
" 	12th Sep 2007 
" 	(*) support "namespace NS1 { namespace NS2 {" on a same line
"
" 	07th Oct 2006
" 	(*) Renamed from ftplugin/cpp/cpp_FindContextClass.vim to
" 	autoload/lh/cpp/AnalysisLib_Class.vim
"
" 	16th May 2006
" 	(*) Bug fix: "using namespace" was misdirecting lh#cpp#AnalysisLib_Class#CurrentScope(), and
" 	    :GOTOIMPL as a consequence.
" 	29th Apr 2005
" 	(*) Not misdriven anymore by:
" 	    - forward declaration in namespaces
" 	      -> "namespace N {class foo;} namespace M{ class bar{}; }"
" 	09th Feb 2005
" 	(*) class_token += enum\|union
" 	(*) Not misdriven anymore by:
" 	    - consecutive classes
" 	      -> "namespace N {class foo {}; class bar{};}"
" 	    - comments
" 	16th dec 2002
" 	(*) Bug fixed regarding forwarded classes.
" 	16th oct 2002
" 	(*) Able to handle C-definitions like 
" 	    "typedef struct foo{...} *PFoo,Foo;"
" 	(*) An inversion problem, with nested classes, fixed.
" 	(*) Cpp_SearchClassDefinition becomes obsolete. Instead, use
" 	    lh#cpp#AnalysisLib_Class#CurrentScope(lineNo, scope_type) to search for a 
" 	    namespace::class scope.
" 	11th oct 2002
" 	(*) Cpp_SearchClassDefinition supports: 
" 	    - inheritance -> 'class A : xx B, xx C ... {'
" 	    - and declaration on several lines of the previous inheritance
" 	    text.
" 	(*) Functions that will return the list of the direct base classes of
" 	    the current class.
"
" TODO: {{{2
" (*) Support templates -> A<T>::B, etc
" (*) Must we differentiate anonymous namespaces from the global namespace ?
" (*) reinject implicit context in #Ancestors
" }}}1
" ==========================================================================
let s:cpo_save = &cpo
set cpo&vim
" ==========================================================================
" Internal constant regexes {{{1
" Note: this regex can be tricked with nasty comments
let s:id              = '\(\<\I\i*\>\)'
let s:class_token     = '\<\(class\|struct\|enum\|union\)\>'
let s:class_part      = s:class_token  . '\_s\+' . s:id
let s:namespace_token = '\<\(namespace\)\>\_s\+'
let s:namespace_part  = s:namespace_token . s:id

let s:both_token     = '\<\(class\|struct\|enum\|union\|namespace\)\>'
let s:both_part      = s:both_token  . '\_s\+' . s:id
" let s:namespace_part = '\<\(namespace\)\>\_s\+' . s:id . '\='
" Use '\=' for anonymous namespaces

" let s:class_open      = '\_.\{-}{'
" '.' -> '[^;]' in order to avoid forward declarations.
let s:class_open00    = '\_[^;]\{-}{'
let s:class_open      = '\_[^;]\{-}'
let s:class_close     = '}\%(\_s\+\|\*\=\s*\<\I\i*\>,\=\)*;'
  "Note: '\%(\_s*\|\*=\s*\<\I\i*\>,\=\)*' is used to accept C typedef like :
  "  typedef struct foo {...} *PFoo, Foo;
let s:namespace_open00= '\_s*{'
let s:namespace_open  = '\_s*'
let s:namespace_close = '}'
" }}}1
" ==========================================================================
" Debug oriented command {{{1
if exists('g:force_load_cpp_FindContextClass')
  command! -nargs=1 CppCACEcho :echo s:<arg>
endi

function! lh#cpp#AnalysisLib_Class#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#AnalysisLib_Class#debug(expr)
  return eval(a:expr)
endfunction

" }}}1
" ==========================================================================
" Search for current and most nested namespace/class <internal> {{{

let s:skip_comments = 'synIDattr(synID(line("."), col("."), 0), "name") =~?'
      \ . '"string\\|comment\\|doxygen"'

function! s:SearchBracket()
  let flag = 'bW'
  return searchpair('{', '', '}', flag, s:skip_comments)
endfunction

function! s:CurrentScope(bMove, scope_type)
  let flag = a:bMove ? 'bW' : 'bnW'
  let pos = 'call cursor(' . line('.') . ',' . col('.') . ')'
  let result = line('.')
  while 1
    let result = s:SearchBracket()
    if result <= 0 
      exe pos
      break 
    endif

    let skip_comments = '(synIDattr(synID(line("."), col("."), 0), "name") '
	  \ . '!~? "c\\%(pp\\)\\=Structure")'
    let skip_using_ns = '(getline(".") =~ "using\s*namespace")'
    " let result = searchpair(
	" \ substitute(s:{a:scope_type}_part, '(', '%(', 'g')
	" \ . s:{a:scope_type}_open, '', '{', flag,
	" \ skip_comments)
    let result = searchpair(
	\ substitute(s:both_part, '(', '%(', 'g')
	\ . s:{a:scope_type}_open, '', '{', flag,
	\ skip_comments.'&&'.skip_using_ns)
    if result > 0 
      if getline(result) !~ '.*'.s:{a:scope_type}_token.'.*'
	exe pos
	let result = 0
      endif
      break 
    endif
  endwhile
  return result
endfunction


" obsolete
function! s:CurrentScope000(bMove,scope_type)
  let flag = a:bMove ? 'bW' : 'bnW'
  return searchpair(
	\ substitute(s:{a:scope_type}_part, '(', '%(', 'g')
	\ . s:{a:scope_type}_open00, '', s:{a:scope_type}_close00, flag,
	\ s:skip_comments)
  "Note: '\(..\)' must be changed into '\%(...\)' with search() and
  "searchpair().
endfunction
" }}}
" ==========================================================================
" Search for a class definition (not forwarded definition) {{{
" Checks whether lineNo is in between the '{' at line classStart and its
" '}' counterpart ; in that case, returns "::".className
function! s:SearchClassOrNamespaceDefinition(class_or_ns)
  let pos = 1
  let scope = ''
  let defines = lh#option#get('cpp_defines_to_ignore', '')
  while pos > 0
    let pos = s:CurrentScope(1, a:class_or_ns)
    if pos > 0
      " in case of "ns NS1 { ns NS2 {", filter from cursor to EOL 
      let line = getline(pos)[col('.')-1:]
      if strlen(defines) > 0
	let line = substitute(line, defines, '', 'g')
      endif
      let current_scope = substitute(line,
	    \ '^.\{-}'.s:{a:class_or_ns}_part.'.*$', '\2', '')
      let scope = '::' . current_scope . scope
    endif
  endwhile
  return substitute (scope, '^:\+', '', 'g')
endfunction
" }}}
" ==========================================================================
" Search for a class definition (not forwarded definition) {{{
" Function: Cpp_SearchClassDefinition(lineNo [, bNamespaces])
" Checks whether lineNo is in between the '{' at line classStart and its
" '}' counterpart ; in that case, returns "::".className
function! lh#cpp#AnalysisLib_Class#SearchClassDefinition(lineNo,...)
  " let pos = a:lineNo
  exe a:lineNo
  let scope = s:SearchClassOrNamespaceDefinition('class')
  if (a:0 > 0) && (a:1 == 1)
    let ns = s:SearchClassOrNamespaceDefinition('namespace') 
    let scope = ns . (((""!=scope) && (""!=ns)) ? '::' : '') . scope
  endif
  exe a:lineNo
  return scope
endfunction

" Possible Values:
"  - 'class'
"  - 'namespace'
"  - 'any'
function! lh#cpp#AnalysisLib_Class#CurrentScope(lineNo, scope_type)
  exe a:lineNo
  if a:scope_type =~ 'any\|##'
    let scope = s:SearchClassOrNamespaceDefinition('class')
    let ns = s:SearchClassOrNamespaceDefinition('namespace') 
    let scope = ns . (((""!=scope) && (""!=ns)) 
	  \ ? ((a:scope_type == '##') ? '#::#' : '::') 
	  \ : '') . scope
  elseif a:scope_type =~ 'class\|namespace'
    let scope = s:SearchClassOrNamespaceDefinition(a:scope_type)
  else
    echoerr 'lh#cpp#AnalysisLib_Class#CurrentScope(): the only ' . 
	  \ 'scope-types accepted are {class}, {namespace} and {any}!'
    return ''
  endif
  exe a:lineNo
  return scope
endfunction
" }}}
" ==========================================================================
" Function: lh#cpp#AnalysisLib_Class#search_closest_class(line) {{{
function! lh#cpp#AnalysisLib_Class#search_closest_class(line)
  " We can't use search('class|struct', b') as it will not distinguish
  " "class foo" from "template <class Foo> void f()"
  " So, we'll use ctags for now, and libclang in the future
  try
    let tags = lh#dev#start_tag_session()
    " tags generated by lh#dev#start_tag_session() have a line field
    let tags = filter(copy(tags), 'v:val.kind=~"[sc]" && v:val.line < a:line')
    " and they are sorted by lines numbers...
    if empty(tags)
      call lh#common#error_masg("No class defintion upstream")
      return ''
    else
      return tags[-1].name
    endif
  finally
    call lh#dev#end_tag_session()
  endtry
endfunction
" }}}
" ==========================================================================
" Search for templates specs <internal> {{{
function! s:TemplateSpecs()
endfunction
" }}}
" ==========================================================================
" Search for the direct base classes <internal> <deprecated> {{{
function! s:BaseClasses0(pos)
  " a- Retrieve the declaration: 'class xxx : yyy {' zone limits {{{
  let pos = a:pos
  let end_pos = line('$')
  let decl = ''
  while pos < end_pos
    " Concat lines and strip comments on the way to the '{'.
    let text = substitute(getline(pos), '/\*.\{-}\*/\|//.*$', '', 'g')
    let decl = decl . ' ' . text
    if text =~ '{' | break | endif
    let pos = pos + 1
  endwhile
  " }}}
  " b- Get the base classes only {{{
  let base = substitute(decl, '^.*'.s:class_part.'[^:]*:\([^{]*\){.*$', '\3','')
  let base = substitute(base, 'public',    '+', 'g')
  let base = substitute(base, 'protected', '#', 'g')
  let base = substitute(base, 'private',   '-', 'g')
  let base = substitute(base, '\s*', '', 'g')
  let base = substitute(base, ',', ', ', 'g')
  " }}}
  return base
endfunction
function! lh#cpp#AnalysisLib_Class#BaseClasses0(lineNo)
  exe a:lineNo
  let pos = s:CurrentScope(1, 'class')
  exe a:lineNo
  return (pos > 0) ? s:BaseClasses0(pos) : ''
endfunction
" }}}
" ==========================================================================
" Search for the base classes {{{
" @todo determine the access rigths
" @todo get children
" @todo get all public functions
" @todo get available functions
" @todo get overidable functions
" @todo follow typedefs

function! lh#cpp#AnalysisLib_Class#GetClassTag(id)
  call lh#common#error_msg("lh#cpp#AnalysisLib_Class#GetClassTag is deprecated, use lh#dev#class#get_class_tag() instead")
  return lh#dev#option#call('class#get_class_tag', &ft, a:id)
endfunction


function! lh#cpp#AnalysisLib_Class#FetchDirectParents(id)
  call lh#common#error_msg("lh#cpp#AnalysisLib_Class#FetchDirectParents is deprecated, use lh#dev#class#fetch_direct_parents() instead")
  return lh#dev#option#call('class#fetch_direct_parents', &ft, a:id)
endfunction

function! lh#cpp#AnalysisLib_Class#Ancestors(id)
  call lh#common#error_msg("lh#cpp#AnalysisLib_Class#Ancestors is deprecated, use lh#dev#class#ancestors() instead")
  return lh#dev#option#call('class#ancestors', &ft, a:id)
endfunction

" }}}
" ==========================================================================
" Search for the child classes {{{1
" a:namespace_where_to_search is a hack because listing all element to extract
" classes is very slow!
" lh#cpp#AnalysisLib_Class#FetchDirectChildren(id, namespace_where_to_search [, recheck_namespace])
function! lh#cpp#AnalysisLib_Class#FetchDirectChildren(id, namespace_where_to_search, ...)
  call lh#common#error_msg("lh#cpp#AnalysisLib_Class#FetchDirectChildren is deprecated, use lh#dev#class#fetch_direct_children() instead")
  return lh#dev#option#call('class#fetch_direct_children', &ft, a:id)
endfunction

" }}}1
" ==========================================================================
" List of imported namespaces {{{1
" Function: lh#cpp#AnalysisLib_Class#used_namespace([up_to]) {{{3
" @return list of imported namespaces
" @todo take the "namespace xx {" scop into account
function! lh#cpp#AnalysisLib_Class#used_namespaces(...)
  let up_to_line = (a:0>0) ? (a:1) : line('$')
  let imported_ns = map( 
        \filter(
        \    getline(1,up_to_line), 
        \    'v:val =~ "^\\s*using\\s\\+namespace"'),
        \ 'matchstr(v:val, "^\\s*using\\s\\+namespace\\s\\+\\zs.\\{-}\\ze\\s*;")'
        \ )
  return imported_ns
endfunction
" ==========================================================================
" Fetch Attributes {{{1
function! lh#cpp#AnalysisLib_Class#attributes(id)
  call lh#common#error_msg("lh#cpp#AnalysisLib_Class#attributes is deprecated, use lh#dev#class#attributes() instead")
  return lh#dev#option#call('class#attributes', &ft, a:id)
endfunction
" }}}1
" ==========================================================================
let &cpo = s:cpo_save
" ========================================================================
" vim60: set fdm=marker:
