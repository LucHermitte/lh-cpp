"=============================================================================
" $Id$
" File:		autoload/lh/cpp/constructors.vim                          {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	09th Feb 2009
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:
" 	Helper MMIs to generate constructors 
" 	Deported functions used by ftplugin/cpp/cpp_Constructor.vim
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	
" 	v1.1.0: Creation
" TODO:		
" - select all attributes by default
" - permit to change the order of the attributes in the constructor parameters
"   list (with <c-up>, <c-down> for instance
" - align parameters on multiple lines, and init-lists
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------

" ## Functions {{{1
" # Debug {{{2
function! lh#cpp#constructors#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    call lh#common#echomsg_multilines(a:expr)
  endif
endfunction

function! lh#cpp#constructors#debug(expr)
  return eval(a:expr)
endfunction

" # API {{{2
" Function: s:Attributes(classname) {{{3
function! s:Attributes(classname)
  " fetch the attributes
  let attributes = lh#cpp#AnalysisLib_Class#attributes(a:classname)
  " The attributes need to be sorted by their order of definition in the class
  " definition

  " todo: do not assume the attributes comes from the same file/class
  if len(attributes) == 0 | return attributes | endif
  for attr in attributes
    let signature = attr.cmd
    let attr['fullsignature' ] = s:Regex2Sig(signature)
  endfor
  unlet attr

  let filename = attributes[0].filename
  let buffer = readfile(filename)
  let search = join(lh#list#transform(attributes,[], 'escape(matchstr(v:1_.cmd,"/^\\s*\\zs.*\\ze\\s*;"),"*")'), '\|')
  call filter(buffer, 'v:val =~ '.string(search))
  call map(buffer, 'matchstr(v:val,"\\s*\\zs.*\\ze\\s*;")')
  let sorted_attributes = []
  for attr in buffer
    let p = lh#list#Find_if(attributes, 'v:val.fullsignature == '.string(attr))
    " assert p!=-1
    if p == -1
      throw "lh#cpp#constructors.s:Attributes: unexpected attribute"
    endif
    call add(sorted_attributes, attributes[p])
  endfor

  return sorted_attributes
endfunction

" # Main {{{2
function! lh#cpp#constructors#Main()
  " 1- Obtain current class name
  let classname = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'),'any')
  call s:Verbose ("classname=".classname)
  " 2- Obtain attributes functions
  let attributes = s:Attributes(classname)
  if exists('g:decls') | unlet g:decls | endif
  let g:decls = attributes
  call s:Verbose ("attributes=".join(attributes,"\n"))

  " 3- Propose to select the functions to override
  call s:Display(classname, attributes)
  " 4- Insert them in the current class
  " -> asynchrounous
endfunction

" # GUI {{{2

" ==========================[ Menu ]====================================
" Function: s:Access(attr) {{{3
function! s:Access(attr)
  if has_key(a:attr, 'access')
    if     a:attr.access == 'public'    | return '+'
    elseif a:attr.access == 'protected' | return '#'
    elseif a:attr.access == 'private'   | return '-'
    else                              | return '?'
    endif
  else                                | return '?'
  endif
endfunction

function! s:Regex2Sig(regex)
  let sig = substitute(a:regex, '/^\s*\(.\{-}\)\s*;\s*\$/', '\1', '')
  return sig
endfunction

" Function: s:AddToMenu(lines, attrs) {{{3
function! s:AddToMenu(lines, attrs)
  " 1- Compute max function length
  let max_length = 0
  let attrs=[]
  " for overloads in a:attrs
    " for attr in overloads
    for attr in a:attrs
      " this damned ctags does not store the type of the attribute ...
      let length = strlen(attr.fullsignature)
      if length > max_length | let max_length = length | endif
      call add(attrs, attr)
    endfor
  " endfor

  " 2- Build the result
  for attr in attrs
    let line = s:Access(attr).' '.attr.fullsignature 
	  \ . repeat(' ', max_length-strlen(attr.fullsignature))
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
	\ 'Construct-Initializable fields for '.a:className,
	\ 'bot below',
	\ 1,
	\ 'lh#cpp#constructors#select',
	\ choices
	\)
  call lh#buffer#dialog#add_help(b_id, '@| +==public, #==protected, -==private in one of the ancestor class', 'long')
  " Added the lonely functions to the b_id
  let b_id['declarations'] = a:declarations
  let b_id['classname']    = a:className
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
    " syntax match CTRtype /.\{-}$/ contained nextgroup=CTRname
    syntax match CTRname /\S*\s*$/ contained
    syntax match CTRtagged /^\*/ contained
    " syntax match UFFile /^  [^-][^[]\+/ contained nextgroup=UFText
    " syntax match UFText /| No .* found for / contained nextgroup=UFSignature
    syntax region CTRLine  start='^[ *] [^-]' end='$' contains=CTRtagged,CTRtype,CTRname

    syntax region CTRExplain start='@' end='$' contains=CTRStart
    syntax match CTRStart /@/ contained
    syntax match Statement /--abort--/

    " Help
    highlight link CTRExplain Comment
    highlight link CTRStart Ignore

    " Lines
    highlight link CTRLine type
    highlight link CTRtagged Statement
    " highlight link CTRtype Comment
    highlight link CTRname Identifier
  endif
endfunction

" Function: lh#cpp#constructors#select(results) {{{3
function! lh#cpp#constructors#select(results)
  if len(a:results.selection)==1 && a:results.selection[0]==0
    call lh#buffer#dialog#quit()
    return
  endif
  if exists('s:quit') | :quit | endif

  " let unmatched = b:dialog.unmatched
  " let cmd = b:cmd

  " let choices = a:results.dialog.choices
  let sig_params = []
  let init_list  = []
  for selection in a:results.selection
    " echomsg '-> '.choices[selection]
    " echomsg '-> '.info[selection-1].filename . ": ".info[selection-1].cmd
    " 
    let one_selected_attr = a:results.dialog.declarations[selection-1]
    let attrb_type = matchstr(one_selected_attr.fullsignature, '^\s*\zs.\{-}\s\+\ze\S\+\s*$')
    let attrb_name = matchstr(one_selected_attr.fullsignature, '^\s*.\{-}\s\+\zs\S\+\ze\s*$')
    let param_name = lh#cpp#style#attribute2parameter_name(attrb_name)

    call add(sig_params, lh#cpp#types#ConstCorrectType(attrb_type).param_name)

    call add(init_list, attrb_name.'('.param_name.')')
    " echomsg string(selected_virt)

  endfor
  let g:results = a:results


  " 0- prepare the init-ctr signature
  let len = eval(lh#list#accumulate(sig_params, 'strlen', 'join(v:1_,  "+")'))
   \ + strlen(a:results.dialog.classname) + 2*len(sig_params) 
   \ + 3 " ();
  if len > &tw-&sw
    let sig = [a:results.dialog.classname . '(' ]
    call extend(sig, lh#list#transform(sig_params[0:len(sig_params)-2], [], 'v:1_ . ","'))
    call add(sig, sig_params[-1].')')
    let header_lines = sig
  else
    let sig = a:results.dialog.classname.'('. join(sig_params, ', ') . ')'
    let header_lines = [substitute(sig, '\s\+', ' ', 'g')]
  endif
  let impl_lines       = deepcopy(header_lines)
  let header_lines[-1] .= ';' 

  " 1- insert it in the .h
  " Go back to the original buffer, and insert the built lines
  let where_it_started = a:results.dialog.where_it_started
  call lh#buffer#find(where_it_started[0])
  if 0==append(where_it_started[1]-1, header_lines)
    exe (where_it_started[1]-1).',+'.(len(header_lines)-1).'normal! =='
    call s:Verbose((where_it_started[1]-1).',+'.(len(header_lines)-1).'normal! ==')
  endif
  " todo: auto-dox

  " 2- insert the default impl (see gotoimpl) in the .cpp, don't forget the
  " init-list
  let impl_lines[0] = a:results.dialog.classname . '::' . impl_lines[0]
  call add(impl_lines, ': '.init_list[0])
  call extend(impl_lines, lh#list#transform(init_list[1:], [], '", ".v:1_'))
  call extend(impl_lines, [ '{', '}'])
  let impl = join(impl_lines, "\n")
  call lh#cpp#GotoFunctionImpl#open_cpp_file()
  call lh#cpp#GotoFunctionImpl#insert_impl(impl)
endfunction

"------------------------------------------------------------------------
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
