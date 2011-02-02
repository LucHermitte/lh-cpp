"=============================================================================
" $Id$
" File:		autoload/lh/cpp/override.vim                              {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	15th Apr 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	«description»
" 
"------------------------------------------------------------------------
" Installation:	
" 	ctags requirements: fields: m: implementation, i: inheritance
" History:	«history»
" TODO:		
" (*) Cache the LoadTags accesses until the related tags file is updated
" (*) Sort result:
"     - first: the less overridden functions
"     - last: the ones already overridden for the current class
" (*) Build and insert the prototypes ; try to fetch the doc as well
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------

" ## Functions {{{1
" # Debug {{{2
function! lh#cpp#override#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

" # API {{{2
" Function: s:OverrideableFunctions(classname) {{{3
function! s:OverrideableFunctions(classname)
  let result = {}
  " todo: do not sort ancestors (find the inheritance (tree) order) because
  " some virtual functions are not marked virtual in childs
  let ancestors = lh#dev#class#ancestors(a:classname)
  " Build the list of inherited overrideable functions
  for base in ancestors
    " - "::" because "inherits:" does not resolves the contextual namespaces
    "   (see omnicppcomplete for a better Ancestors function ?)
    " - "\>" strips the symbols from nested classes
    let base_pattern = ((base =~ '::') ? '^' : '::') . base . '\>'
    let functions = lh#cpp#AnalysisLib_Function#LoadTags(base_pattern)
    let declarations = lh#cpp#AnalysisLib_Function#SearchAllDeclarations(functions)
    " - only keep virtual functions
    let virtual_fcts = filter(declarations, 'v:val.implementation =~ "virtual"')
    for fn in virtual_fcts
      let fn2 = copy(fn)
      let name    = matchstr(fn.name, '^[^(]*::\zs.*$')
      let context = matchstr(fn.name, '^[^(]*::\ze.*$')
      let fn2.contexts = [ context ]
      let fn2.name  = name

      if !has_key(result, name)
	let result[name] = [ fn2 ]
      else
	for overload in result[name]
	  if lh#cpp#AnalysisLib_Function#IsSame(overload, fn2)
	    " an override
	    call add(overload.contexts, context)
            " echomsg "SAME: " . string(overload). " -- " . string(fn2)
	  else
	    " new overload
	    call add(result[name], fn2)
            " echomsg "DIFF: " . string(overload). " -- " . string(fn2)
	  endif
	endfor
      endif
    endfor
    " echomsg "fct(".base."=".string(virtual_fcts)
  endfor

  " And now Identify which functions are already overridden
  " ::classname\> is no good with tagslist ...
  " let class_pattern = ((a:classname =~ '::') ? '^' : '::') . a:classname . '\>'
  let class_pattern = '\<' . a:classname . '\>'
  let functions = lh#cpp#AnalysisLib_Function#LoadTags(class_pattern)
  let declarations = lh#cpp#AnalysisLib_Function#SearchAllDeclarations(functions)
  " don't restrict to virtual as sometimes it is implicit
  " let virtual_fcts = filter(declarations, 'v:val.implementation =~ "virtual"')
  for fn in declarations
    let name    = matchstr(fn.name, '^[^(]*::\zs.*$')
    let fn.name = name
    if has_key(result, name)
      for overload in result[name]
	if lh#cpp#AnalysisLib_Function#IsSame(overload, fn)
	  " an override
	  let overload.overriden = 1
          echomsg "SAME: " . string(overload). " -- " . string(fn)
        else
          echomsg "DIFF: " . string(overload). " -- " . string(fn)
	endif
      endfor
    endif
  endfor

  let flattened = []
  for decl in values(result)
    call extend(flattened, decl)
  endfor
  return flattened
endfunction

" Function: s:OverrideFunction(function_tag) {{{3
function! s:OverrideFunction(function_tag)
  " a- open the related file in a new window
  let filename = a:function_tag.filename
  exe 'sp '.filename
  try 
    " b- search the exact signature
    let signature = a:function_tag.fullsignature
    let g:signature = signature
    let regex_signature = lh#cpp#AnalysisLib_Function#SignatureToSearchRegex(signature, '').regex
    " todo: support embedded comment within the optional "= 0" part
    let regex_signature .= '\s*\(=\s*0\s*\)\=;' 
    let lineno = search(regex_signature)
    if lineno <= 0
      throw "Override: cannot find ".signature." declaration in ".filename
    endif
    " c- extract all the relevant text (beware of =0)
    let code = lh#cpp#AnalysisLib_Function#GetFunctionPrototype(lineno, 1)
    let code = substitute(code, '\s*=\s*0\s*;$', '', '')
  finally
    " quit the split-opened window
    :q
  endtry
    " d- copy the function back.
    " todo: open all the related files in a scratch buffer, and fetch the exact
    " signatures + the comments
    let lines = []
    call add(lines, code.';') " where is the return type ?
    call add(lines, '')
    return lines
endfunction

" # Main {{{2
function! lh#cpp#override#Main()
  " 1- Obtain current class name
  let classname = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'),'any')
  call s:Verbose ("classname=".classname)
  " 2- Obtain overrideable functions
  let virtual_fcts = s:OverrideableFunctions(classname)
  call s:Verbose ("virtual fct=".string(virtual_fcts))
  let g:decls = virtual_fcts

  " 3- Propose to select the functions to override
  call s:Display(classname, virtual_fcts)
  " 4- Insert them in the current class
  " -> asynchrounous
endfunction

" # GUI {{{2
" ==========================[ Menu ]====================================
" Function: s:Access(fn) {{{3
function! s:Access(fn)
  if has_key(a:fn, 'access')
    if     a:fn.access == 'public'    | return '+'
    elseif a:fn.access == 'protected' | return '#'
    elseif a:fn.access == 'private'   | return '-'
    else                              | return '?'
    endif
  else                                | return '?'
  endif
endfunction

function! s:Overriden(fn)
  return has_key(a:fn, 'overriden') ? '!' : ' '
endfunction

" Function: s:AddToMenu(lines, fns) {{{3
function! s:AddToMenu(lines, fns)
  " 1- Compute max function length
  let max_length = 0
  let fns=[]
  " for overloads in a:fns
    " for fn in overloads
    for fn in a:fns
      let signature = lh#cpp#AnalysisLib_Function#BuildSignatureAsString(fn)
      let fn['fullsignature' ] = signature
      let length = lh#encoding#strlen(signature)
      if length > max_length | let max_length = length | endif
      call add(fns, fn)
    endfor
  " endfor

  " 2- Build the result
  for fn in fns
    let line = s:Overriden(fn).s:Access(fn).' '.fn.fullsignature 
	  \ . repeat(' ', max_length-lh#encoding#strlen(fn.fullsignature))
	  \ . ' ' . string(fn.contexts)
    call add(a:lines, line)
  endfor
endfunction

" Function: s:BuildMenu(declarations) {{{3
function! s:BuildMenu(declarations)
  let res = ['--abort--']
  call s:AddToMenu(res, a:declarations)
  return res
endfunction

" Function: s:Display(className, declarations) {{{3
function! s:Display(className, declarations)
  let choices = s:BuildMenu(a:declarations)
  " return
  let b_id = lh#buffer#dialog#new(
	\ 'C++Override('.substitute(a:className, '[^A-Za-z0-9_.]', '_', 'g' ).')',
	\ 'Overrideable functions for '.a:className,
	\ 'bot below',
	\ 1,
	\ 'lh#cpp#override#select',
	\ choices
	\)
  call lh#buffer#dialog#add_help(b_id, '@| !==already overridden function in '.a:className, 'long')
  call lh#buffer#dialog#add_help(b_id, '@| +==public, #==protected, -==private in one of the ancestor class', 'long')
  " Added the lonely functions to the b_id
  let b_id['declarations'] = a:declarations
  " Syntax and co
  call s:PostInitDialog()
  return ''
endfunction

" Function: s:PostInitDialog() {{{3
function! s:PostInitDialog()
  if has("syntax")
    syn clear

    " todo: fix syntax names
    " syntax region UFNbOcc  start='^--' end='$' contains=UFNumber,UFName
    syntax match UFSignature /.*$/ contained
    syntax match UFFile /^  [^-][^[]\+/ contained nextgroup=UFText
    syntax match UFText /| No .* found for / contained nextgroup=UFSignature
    syntax region UFLine  start='^  [^-]' end='$' contains=UFFile,UFText,UFSignature

    syntax region UFExplain start='@' end='$' contains=UFStart
    syntax match UFStart /@/ contained
    syntax match Statement /--abort--/

    " Help
    highlight link UFExplain Comment
    highlight link UFStart Ignore

    " Lines
    highlight link UFLine Normal
    highlight link UFFile Directory
    highlight link UFText Normal
    highlight link UFSignature Identifier
  endif
endfunction

" Function: lh#cpp#override#select(results) {{{3
function! lh#cpp#override#select(results)
  if len(a:results.selection)==1 && a:results.selection[0]==0
    call lh#buffer#dialog#quit()
    return
  endif
  if exists('s:quit') | :quit | endif

  " let unmatched = b:dialog.unmatched
  " let cmd = b:cmd

  let choices = a:results.dialog.choices
  let lines = []
  for selection in a:results.selection
    " echomsg '-> '.choices[selection]
    " echomsg '-> '.info[selection-1].filename . ": ".info[selection-1].cmd
    " 
    let selected_virt = a:results.dialog.declarations[selection-1]
    " echomsg string(selected_virt)
    call extend(lines, s:OverrideFunction(selected_virt))
  endfor
  " Go back to the original buffer, and insert the built lines
  let where_it_started = a:results.dialog.where_it_started
  call lh#buffer#find(where_it_started[0])
  if 0==append(where_it_started[1]-1, lines)
    exe (where_it_started[1]-1).',+'.(len(lines)-1).'normal! =='
    echo (where_it_started[1]-1).',+'.(len(lines)-1).'normal! =='
  endif
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
