"=============================================================================
" File:         autoload/lh/cpp/constructors.vim                          {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/blob/master/License.md>
" Version:      2.3.0
" Created:      09th Feb 2009
" Last Update:  11th Mar 2021
"------------------------------------------------------------------------
" Description:
"       Helper MMIs to generate constructors
"       Deported functions used by ftplugin/cpp/cpp_Constructor.vim
"
"------------------------------------------------------------------------
" History:
"       v1.1.0: Creation
"       v2.0.0  31st May 2012
"               License GPLv3 w/ extension
"       v.2.0.0b4
"               New commands: :ConstructorCopy, :ConstructorDefault,
"               :ConstructorInit, :AssignmentOperator
" Requirements:
"       - mu-template 3.0.8
"       - lh-dev
" TODO:
" - select all attributes by default
" - permit to change the order of the attributes in the constructor parameters
"   list (with <c-up>, <c-down> for instance
" - align parameters on multiple lines, and init-lists
" - have init-constructors rely on a mu-template snippet
" - rely of libclang (databases?)
" - Extend to C++11 move constructors & co
" - Use universal ctags typeref attribute when available to obtain types
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

function! lh#cpp#constructors#debug(expr) abort
  return eval(a:expr)
endfunction

" # API {{{2
"Function: lh#cpp#constructors#Main {{{3
function! lh#cpp#constructors#Main(...) abort
  if a:0 == 0 || a:1 == 'init'
    call lh#cpp#constructors#InitConstructor()
  elseif a:1 =~ 'assign'
    call lh#cpp#constructors#AssignmentOperator()
  else
    call lh#cpp#constructors#GenericConstructor(a:1)
  endif
endfunction

" Function: lh#cpp#constructors#InitConstructor() {{{3
function! lh#cpp#constructors#InitConstructor() abort
  " 1- Obtain current class name
  let classname = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'),'any')
  call s:Verbose ("classname=".classname)
  " 2- Obtain attributes functions
  let attributes = lh#cpp#AnalysisLib_Class#attributes_sorted_by_decl_order(classname)
  call s:Verbose ("attributes=".join(attributes,"\n"))

  if !empty(attributes)
    " 3- Propose to select the functions to override
    call s:Display(classname, attributes)
    " 4- Insert them in the current class
    " -> asynchrounous
  else
    " 3.bis- do it synchronously
    let where_it_started = getpos('.')
    let where_it_started[0] = bufnr('%')
    call lh#cpp#constructors#_expand_selection(classname, [], [], where_it_started)
  endif
endfunction

" Function: lh#cpp#constructors#AssignmentOperator() {{{3
function! lh#cpp#constructors#AssignmentOperator() abort
  " 1- Obtain current class name
  let classname = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'),'any')
  call s:Verbose ("classname=".classname)
  " 2- Obtain attributes functions
  let attributes = lh#cpp#AnalysisLib_Class#attributes_sorted_by_decl_order(classname)
  call s:Verbose ("attributes=".join(attributes,"\n"))

  " 3- Insert the assignment-operator declaration
  let params = {}
  let params.clsname = classname
  let params.attributes = attributes
  " remove scope from attribute name
  call lh#list#map_on(attributes, 'name', 'substitute(v:val, ".*::", "", "")')
  try
    let cleanup = lh#on#exit()
          \.restore('g:mt_jump_to_first_markers')
    let g:mt_jump_to_first_markers = 0
    call lh#mut#expand_and_jump(0, 'cpp/assignment-operator', params)
  finally
    call cleanup.finalize()
  endtry

  " 4- Move its implementation, if any, to the right place
  if getline('.') =~ '}$'
    normal! %
    while line('.') > 1 && getline('.') =~ '\v^\s*\{|^\s*$'
      normal! k
    endwhile
    call lh#cpp#GotoFunctionImpl#MoveImpl()
  endif
endfunction

" Function: lh#cpp#constructors#GenericConstructor(kind) {{{3
function! lh#cpp#constructors#GenericConstructor(kind) abort
  " 1- Obtain current class name
  let classname = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'),'any')
  call s:Verbose ("classname=".classname)
  " 2- Obtain attributes functions
  let attributes = lh#cpp#AnalysisLib_Class#attributes_sorted_by_decl_order(classname)
  " let g:attributes = attributes
  call s:Verbose ("attributes=".join(attributes,"\n"))

  " 3- Insert the *-constructor declaration
  try
    let cleanup = lh#on#exit()
          \.restore('g:mt_jump_to_first_markers')
    let g:mt_jump_to_first_markers = 0
    exe 'MuTemplate cpp/'.a:kind.'-constructor'
  finally
    call cleanup.finalize()
  endtry

  " 4- Go-to its implementation and fill-it
  " Last line inserted should be the constructor signature
  " 4.1- Prepare init-list code
  " TODO: add option to choose Uniform Initialization Syntax
  let rhs = lh#naming#param('rhs').'.'
  let init_list=[]
  let attr_type_and_name = map(copy(attributes),
        \ '[v:val.type, matchstr(v:val.fullsignature, "^\\s*.\\{-}\\s\\+\\zs\\S\\+\\ze\\s*$")]')
  if a:kind == 'copy'
    let init_list = map(copy(attr_type_and_name),
          \ 'v:val[1]."(".lh#cpp#snippets#duplicate_param(rhs.v:val[1], v:val[0]).")"')
  elseif a:kind == 'default'
    " TODO:
    " - Skip attributes that are default constructibles...
    "   At least we can recognize std containers
    " - Using {} instead of () may also change everything...
    let init_list = map(copy(attr_type_and_name), 'v:val[1]."()"')
  endif

  " 4.2- goto impl is at the right place
  " MOVETOIMPL doesn't know how to ignore initialization-list
  " => We don't use the constructor snippets at their full capacity for now,
  " and thus duplicate their attribute-duplication code.
  call lh#cpp#GotoFunctionImpl#GrabFromHeaderPasteInSource({'init_list' : init_list})
endfunction

" # Internals {{{2
" Function: lh#cpp#constructors#_complete(A,L,P) {{{3
function! lh#cpp#constructors#_complete(A,L,P) abort
  return filter(['init', 'copy', 'default', 'assign'], 'v:val =~ "^".a:A.".*"')
endfunction

" # GUI {{{2

" ==========================[ Menu ]====================================
" Function: s:Access(attr) {{{3
function! s:Access(attr) abort
  if has_key(a:attr, 'access')
    if     a:attr.access == 'public'    | return '+'
    elseif a:attr.access == 'protected' | return '#'
    elseif a:attr.access == 'private'   | return '-'
    else                                | return '?'
    endif
  else                                  | return '?'
  endif
endfunction

" Function: s:AddToMenu(lines, attrs) {{{3
function! s:AddToMenu(lines, attrs) abort
  " 1- Compute max function length
  let max_length = 0
  let attrs=[]
  " for overloads in a:attrs
    " for attr in overloads
    for attr in a:attrs
      " this damned ctags does not store the type of the attribute ...
      let length = lh#encoding#strlen(attr.fullsignature)
      if length > max_length | let max_length = length | endif
      call add(attrs, attr)
    endfor
  " endfor

  " 2- Build the result
  for attr in attrs
    let line = s:Access(attr).' '.attr.fullsignature
          \ . repeat(' ', max_length-lh#encoding#strlen(attr.fullsignature))
    call add(a:lines, line)
  endfor
endfunction

" Function: s:BuildMenu(declarations) {{{3
function! s:BuildMenu(declarations) abort
  let res = ['--abort--']
  call s:AddToMenu(res, a:declarations)
  return res
endfunction

" Function: s:Display(className, declarations) {{{3
function! s:Display(className, declarations) abort
  let choices = s:BuildMenu(a:declarations)
  " return
  let b_id = lh#buffer#dialog#new(
        \ 'C++Constructor('.substitute(a:className, '[^A-Za-z0-9_.]', '_', 'g' ).')',
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
function! s:PostInitDialog() abort
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

" Function: lh#cpp#constructors#_expand_selection(results) {{{3
function! lh#cpp#constructors#_expand_selection(classname, sig_params, init_list, where_it_started, is_explicit) abort
  " 0- prepare the init-ctr signature
  let len = lh#list#accumulate2(a:sig_params, 0, 'v:1_ + strlen(v:2_)')
   \ + lh#encoding#strlen(a:classname) + 2*len(a:sig_params)
   \ + 3 " ();
  if len > &tw-&sw
    let sig = [a:classname . '(' ]
    call extend(sig, lh#list#transform(a:sig_params[0:len(a:sig_params)-2], [], 'v:1_ . ","'))
    call add(sig, a:sig_params[-1].')')
    let header_lines = sig
  else
    let sig = a:classname.'('. join(a:sig_params, ', ') . ')'
    let header_lines = [substitute(sig, '\s\+', ' ', 'g')]
  endif
  let impl_lines       = deepcopy(header_lines)
  if a:is_explicit
    let header_lines[0] = 'explicit ' . header_lines[0]
  endif
  let header_lines[-1] .= ';'

  " 1- insert it in the .h
  " Go back to the original buffer, and insert the built lines
  call lh#buffer#find(a:where_it_started[0])
  if 0==append(a:where_it_started[1]-1, header_lines)
    exe (a:where_it_started[1]-1).',+'.(len(header_lines)-1).'normal! =='
    call s:Verbose((a:where_it_started[1]-1).',+'.(len(header_lines)-1).'normal! ==')
  endif
  " TODO: auto-dox

  " 2- insert the default impl (see gotoimpl) in the .cpp, don't forget the
  " init-list
  let impl_lines[0] = a:classname . '::' . impl_lines[0]
  if !empty(a:init_list)
    call add(impl_lines, ': '.a:init_list[0])
    if len(a:init_list) > 0
      call extend(impl_lines, lh#list#transform(a:init_list[1:], [], '", ".v:1_'))
    endif
  endif
  call extend(impl_lines, [ '{', '}'])
  let impl = join(impl_lines, "\n")
  call lh#cpp#GotoFunctionImpl#open_cpp_file('')
  call lh#cpp#GotoFunctionImpl#insert_impl(impl)
endfunction

" Function: lh#cpp#constructors#select(results) {{{3
function! lh#cpp#constructors#select(results) abort
  call lh#buffer#dialog#quit()
  if len(a:results.selection)==1 && a:results.selection[0]==0
    " Abort
    return
  endif
  " if exists('s:quit') | :quit | endif

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

    call add(sig_params, lh#dev#cpp#types#ConstCorrectType(attrb_type).' '.param_name)

    call add(init_list, attrb_name.'('.param_name.')')
    " echomsg string(selected_virt)
  endfor


  let classname = a:results.dialog.classname
  call lh#cpp#constructors#_expand_selection(classname,
        \ sig_params, init_list,
        \ a:results.dialog.where_it_started,
        \ len(a:results.selection) == 1)
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
