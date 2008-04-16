"=============================================================================
" $Id$
" File:		override.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	1.0.0
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
" # API {{{2
function! s:OverrideableFunctions(classname)
  let result = {}
  " todo: do not sort ancestors (find the inheritance (tree) order) because
  " some virtual functions are not marked virtual in childs
  let ancestors = lh#cpp#AnalysisLib_Class#Ancestors(a:classname)
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
	  else
	    " new overload
	    call add(result[name], fn2)
	  endif
	endfor
      endif
    endfor
    " echomsg "fct(".base."=".string(virtual_fcts)
  endfor

  " And now Identify which functions are already overridden
  let class_pattern = ((a:classname =~ '::') ? '^' : '::') . a:classname . '\>'
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
	endif
      endfor
    endif
  endfor
  return values(result)
endfunction

" # Main {{{2
function! lh#cpp#override#Main()
  " 1- Obtain current class name
  let classname = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'),'any')
  " 2- Obtain overrideable functions
  let virtual_fcts = s:OverrideableFunctions(classname)

  " 3- Propose to select the functions to override
  call s:Display(classname, virtual_fcts)
  " 4- Insert them in the current class
  " -> asynchrounous
endfunction

" # GUI {{{2
" ==========================[ Menu ]====================================
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

function! s:AddToMenu(lines, fns)
  " 1- Compute max function length
  let max_length = 0
  let fns=[]
  for overloads in a:fns
    for fn in overloads
      let signature = lh#cpp#AnalysisLib_Function#BuildSignatureAsString(fn)
      let fn['fullsignature' ] = signature
      let length = strlen(signature)
      if length > max_length | let max_length = length | endif
      call add(fns, fn)
    endfor
  endfor

  " 2- Build the result
  for fn in fns
    let line = s:Overriden(fn).s:Access(fn).' '.fn.fullsignature 
	  \ . repeat(' ', max_length-strlen(fn.fullsignature))
	  \ . ' ' . string(fn.contexts)
    call add(a:lines, line)
  endfor
endfunction

function! s:BuildMenu(declarations)
  let res = ['--abort--']
  call s:AddToMenu(res, a:declarations)
  return res
endfunction

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

function! lh#cpp#override#select(results)
  if len(a:results.selection)==1 && a:results.selection[0]==0
    call lh#buffer#dialog#Quit()
    return
  endif
  if exists('s:quit') | :quit | endif

  " let unmatched = b:dialog.unmatched
  " let cmd = b:cmd

  let choices = a:results.dialog.choices
  for selection in a:results.selection
    echomsg '-> '.choices[selection]
    " echomsg '-> '.info[selection-1].filename . ": ".info[selection-1].cmd
    " 
    let selected_virt = a:results.dialog.declarations[selection-1]
    echomsg string(selected_virt)
    continue
    call lh#buffer#Find(selected_virt.filename)
    normal! gg
    try
      " todo: save history and @/
      let save_magic = &magic
      set nomagic
      exe selected_virt.cmd
    finally
      let &magic = save_magic
    endtry
  endfor
endfunction


"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
