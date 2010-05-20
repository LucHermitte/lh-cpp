" ========================================================================
" $Id$
" File:		autoload/lh/cpp/AnalysisLib_Class.vim                 {{{1
" Author:	Luc Hermitte <MAIL:hermitte at free.fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
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
" 	(*) Bug fix: "using namespace" was misdirecting Cpp_CurrentScope(), and
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
" 	    Cpp_CurrentScope(lineNo, scope_type) to search for a 
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
" Debug oriented command
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
    echoerr 'cpp_FindContextClass.vim::Cpp_CurrentScope(): the only ' . 
	  \ 'scope-types accepted are {class}, {namespace} and {any}!'
    return ''
  endif
  exe a:lineNo
  return scope
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
  let tags = taglist(a:id)
  " In C++, a struct is a class, but with different default access rights
  let class_tags = filter(copy(tags), 'v:val.kind=~"[sc]"')
  return class_tags
endfunction

" Return the information already known, or do fetch it in CTags base
function! s:DoFetchClasses(id, instance)
  if has_key(a:instance, a:id)
    return a:instance[a:id]
  else
    let classes = lh#cpp#AnalysisLib_Class#GetClassTag('^'.a:id.'$')
    let a:instance[a:id] = classes
    return classes
  endif
endfunction

function! lh#cpp#AnalysisLib_Class#FetchDirectParents(id)
  let parents = []
  if !exists('s:instance')
    let s:instance = {}
  endif
  " 1- Fetch the tags associated to classes names a:id
  let classes = s:DoFetchClasses(a:id, s:instance)
  " select the classes that inherit from another ... in order to found their parents
  call filter(classes, 'has_key(v:val, "inherits")')
  " 2- Select the best match for the a:id class
  if len(classes) > 1
    echomsg "Warning lh#cpp#AnalysisLib_Class#FetchDirectParents: has detected several classes named `".a:id."'"
  endif
  for class in classes
    " 3- Look at its parents
    let sParents = class.inherits
    " echomsg "[".a:id.']'.class.name . " inherits " . sParents
    let lParents = split(sParents, ',')
    " 4- Keep the best candidates as parents
    " todo: select the class that better matches the current context (imported
    " namespaces, and current namespace)
    "    -> omni#cpp#namespaces#GetContexts()
    "    How can we obtain the exact parent names without fetching them ahead ?
    "    Or may be we need to fetch (and cache them ahead)... <-------- GO for this one!
    "
    " 4.a- open a scratch buffer, goto class definition, check its context
    " 4.b- compare each parent with the context
    " 4.c- save the exact good parents
    call extend(parents, lParents)
  endfor
  return parents
endfunction

function! lh#cpp#AnalysisLib_Class#Ancestors(id)
  try
    let s:instance = {}
    let parents = lh#graph#tsort#depth(function('lh#cpp#AnalysisLib_Class#FetchDirectParents'), [a:id])
    " and then remove the first node: a:id
    call remove(parents, 0)
    " echomsg string(parents)
    return parents
  catch /Tsort.*/
    let cycle = matchstr(v:exception, '.*: \zs.*')
    throw "Cycle in ".a:id." inheritance tree detected: ".cycle
  finally
    unlet s:instance
  endtry
endfunction

" With:
"   struct V {};
"   struct C1 : virtual V {};
"   struct C2 : virtual V {};
"   struct C3 : C2{};
"   struct D : C1, C3 {};
" ":Parent D" must return: [C1, C3, C2, V] 
" (at least, we must see: C1 < V, and C3 < C2 < V)
" }}}
" ==========================================================================
" Search for the child classes {{{1
" a:namespace_where_to_search is a hack because listing all element to extract
" classes is very slow!
" lh#cpp#AnalysisLib_Class#FetchDirectChildren(id, namespace_where_to_search [, recheck_namespace])
function! lh#cpp#AnalysisLib_Class#FetchDirectChildren(id, namespace_where_to_search, ...)
  let children = []
  if !exists('s:instance') || (a:0 > 0 && a:1)
    let s:instance = {}
  endif
  " 1- Fetch the tags associated to classes names a:id
  let classes = s:DoFetchClasses(a:namespace_where_to_search.'::.*', s:instance)
  " select the classes that inherit from another ... in order to found their parents
  call filter(classes, 'has_key(v:val, "inherits") && v:val.inherits=~'.string(a:id))
  " 2- Select the best match for the a:id class
  let children = lh#list#Transform(classes, [], 'v:val.name')
  return children
endfunction

" }}}1
" ==========================================================================
" Fetch Attributes {{{1
function! lh#cpp#AnalysisLib_Class#attributes(id)
  let tags = taglist(a:id)
  let class_tags = filter(copy(tags), 'v:val.kind=~"[sc]" && v:val.name=="'.a:id.'"')
  " overwrite tagnames
  for class in class_tags
    let class.name = lh#tags#tag_name(class)
  endfor
  let class_tags = lh#list#unique_sort2(class_tags)
  " echo join(class_tags, "\n")
  let nb_matches=len(class_tags)
  let struct_class_filter = [0]
  for class in class_tags
    if class.kind == 's'
      call add(struct_class_filter, '(has_key(v:val,"struct") && v:val.struct=="'.class.name.'")')
    elseif class.kind == 'c'
      call add(struct_class_filter, '(has_key(v:val,"class") && v:val.class=="'.class.name.'")')
    endif
  endfor

  let members = filter(copy(tags), 'v:val.kind=="m"')
  let class_filter = join(struct_class_filter, '||')
  call s:Verbose ("filter=". class_filter)
  let members = filter(members, class_filter)
  return members
endfunction
" }}}1
" ==========================================================================
let &cpo = s:cpo_save
" ========================================================================
" vim60: set fdm=marker:
