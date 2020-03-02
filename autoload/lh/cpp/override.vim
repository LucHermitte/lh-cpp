"=============================================================================
" File:         autoload/lh/cpp/override.vim                              {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/tree/master/License.md>
" Version:      2.3.0
let s:k_version = '230'
" Created:      15th Apr 2008
" Last Update:  15th Jan 2020
"------------------------------------------------------------------------
" Description:  «description»
"
"------------------------------------------------------------------------
" Installation:
"       ctags requirements: fields: m: implementation, i: inheritance
" History:      «history»
" TODO:
" (*) Cache the LoadTags accesses until the related tags file is updated
" (*) Sort result:
"     - first: the less overridden functions
"     - last: the ones already overridden for the current class
" (*) Build and insert the prototypes ; try to fetch the doc as well
" (*) Add override C++11 keyword, with vimscript API
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version   {{{2
function! lh#cpp#override#version()
  return s:k_version
endfunction

" # Debug     {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cpp#override#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...)
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...)
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#cpp#override#debug(expr) abort
  return eval(a:expr)
endfunction

" # Script ID {{{2
function! s:getSID() abort
  return eval(matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_getSID$'))
endfunction
let s:k_script_name      = s:getSID()

" ## Functions {{{1
" # API {{{2
" Function: lh#cpp#override#root_function(classname/ancestors, funcname) {{{3
function! lh#cpp#override#root_function(classname, funcname) abort
  let result = []
  " todo: do not sort ancestors (find the inheritance (tree) order) because
  " some virtual functions are not marked virtual in childs
  let ancestors = type(a:classname) == type([]) ? a:classname : lh#dev#class#ancestors(a:classname)
  for base in ancestors
    let functions = taglist('\v<'.base.'>::<'.a:funcname.'>')
    " Shall we make sure they are virtual ?
    " call filter(functions, 'v:val.implementation =~ "virtual"')
    " Shall we make sure the name is correct ?
    " call filter(virtual_fcts, 'v:val.name =~ a:funcname')
    let result += functions
  endfor
  " TODO: filter the root function only. Let's suppose for now that it's the
  " last one.
  " We may have to take care of diamong of hell.
  return result
endfunction

" Function: s:OverrideableFunctions(classname) {{{3
function! s:OverrideableFunctions(classname) abort
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
    let functions = lh#cpp#AnalysisLib_Function#LoadTags(base_pattern, {'remove_pure': 0, 'remove_destructor': 1})
    let declarations = lh#cpp#AnalysisLib_Function#SearchAllDeclarations(functions)
    " - only keep virtual functions
    let virtual_fcts = filter(declarations, 'v:val.implementation =~ "virtual"')
    for fn in virtual_fcts
      let fn2 = copy(fn)
      let name    = matchstr(fn.name, '^[^(]*::\zs.*$')
      let context = matchstr(fn.name, '^[^(]*::\ze.*$')
      let fn2.defined_in = [ context ]
      let fn2.name  = name

      if !has_key(result, name)
        let result[name] = [ fn2 ]
      else
        for overload in result[name]
          if lh#cpp#AnalysisLib_Function#IsSame(overload, fn2)
            " an override
            call add(overload.defined_in, context)
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
function! s:OverrideFunction(function_tag) abort
  " a- open the related file in a new window
  let filename = a:function_tag.filename
  call lh#window#create_window_with('sp '.filename)
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
    let code = substitute(code, '\s*;$', '', '')
  finally
    " quit the split-opened window
    :q
  endtry
    " d- copy the function back.
    " todo: open all the related files in a scratch buffer, and fetch the exact
    " signatures + the comments
    let lines = []
    call add(lines, code.';') " where is the return type ?
    " call add(lines, '')
    return lines
endfunction

" Vimscript API {{{3
function! s:vim_get_classname() abort " {{{4
  let classname = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'),'any')
  return classname
endfunction

function! s:vim_get_overridable_functions(classname) abort " {{{4
  let virtual_fcts = s:OverrideableFunctions(a:classname)
  for fn in virtual_fcts
    let signature = lh#cpp#AnalysisLib_Function#BuildSignatureAsString(fn)
    let fn['fullsignature' ] = signature
  endfor
  return virtual_fcts
endfunction

function! s:vim_override(function_tag, should_paste_comment) abort " {{{4
  " This version isn't able to extract comments/doc
  return s:OverrideFunction(a:function_tag)
endfunction

function! s:make_vimscript_API() abort " {{{4
  let res = lh#object#make_top_type({'API': 'vimscript'})
  call lh#object#inject(res, 'get_classname', 'vim_get_classname', s:k_script_name)
  call lh#object#inject(res, 'get_overridable_functions', 'vim_get_overridable_functions', s:k_script_name)
  call lh#object#inject(res, 'override', 'vim_override', s:k_script_name)
  return res
endfunction

" libclang API {{{3
function! s:libclang_get_classname() abort " {{{4
  let classname = pyxeval('findClass().spelling')
  return classname
endfunction

function! s:libclang_get_overridable_functions(classname) abort " {{{4
  " Given the way it works, we don't need to forward the classname: we will get
  " another cursor to it.
  let virtual_fcts = clang#non_overridden_virtual_functions()
  for fn in virtual_fcts
    let signature = substitute(fn.signature, '(', fn.name.'(', '')
    let fn['fullsignature' ] = signature
  endfor
  return virtual_fcts
endfunction

function! s:libclang_override(function_tag, should_paste_comment) abort " {{{4
  call s:Verbose("Overriding: %1", a:function_tag)
  let lines = []
  if a:should_paste_comment
    let lines += split(a:function_tag.comment, "\n")
  endif
  let lines += clang#extract_from_extent(a:function_tag.extent, a:function_tag.name)
  call s:Verbose("Definition found: %1", lines)
  " TODO: could be "final" instead
  let lines[0]  = substitute(lines[0], '\s*virtual\s\+', '', '')
  let lines[-1]  = substitute(lines[-1], '\s*=\s*0', '', '')
  let lines[-1]  = substitute(lines[-1], '\v(<noexcept>|<throw>|$)', lh#cpp#snippets#override().' &', '')
  let lines[-1]  = substitute(lines[-1], ' *$', ';', '')

  return lines
endfunction

function! s:make_libclang_API() abort " {{{4
  let res = lh#object#make_top_type({'API': 'libclang'})
  call lh#object#inject(res, 'get_classname', 'libclang_get_classname', s:k_script_name)
  call lh#object#inject(res, 'get_overridable_functions', 'libclang_get_overridable_functions', s:k_script_name)
  call lh#object#inject(res, 'override', 'libclang_override', s:k_script_name)
  return res
endfunction

" # Main {{{2
function! lh#cpp#override#Main() abort
  if lh#has#plugin('autoload/clang.vim') && clang#can_plugin_be_used()
    let api = s:make_libclang_API()
  else
    let api = s:make_vimscript_API()
  endif
  " 1- Obtain current class name
  let classname = api.get_classname()
  call s:Verbose ("classname=".classname)
  " 2- Obtain overrideable functions
  let virtual_fcts = api.get_overridable_functions(classname)
  call s:Verbose ("virtual fct=".string(virtual_fcts))
  let g:decls = virtual_fcts

  " 3- Propose to select the functions to override
  call s:Display(classname, virtual_fcts, api)
  " 4- Insert them in the current class
  " -> asynchrounous
endfunction

" # GUI {{{2
" ==========================[ Menu ]====================================
" Function: s:Access(fn) {{{3
function! s:Access(fn) abort
  if has_key(a:fn, 'access')
    if     a:fn.access == 'public'    | return '+'
    elseif a:fn.access == 'protected' | return '#'
    elseif a:fn.access == 'private'   | return '-'
    else                              | return '?'
    endif
  else                                | return '?'
  endif
endfunction

" Function: s:Overriden(fn) {{{3
function! s:Overriden(fn) abort
  return has_key(a:fn, 'overriden') ? '!' : ' '
endfunction

" Function: s:AddToMenu(lines, fns) {{{3
function! s:AddToMenu(lines, fns) abort
  " 1- Compute max function length
  let max_length = 0
  let fns=[]
  " for overloads in a:fns
    " for fn in overloads
    for fn in a:fns
      let signature = fn.fullsignature
      let length = lh#encoding#strlen(signature)
      if length > max_length | let max_length = length | endif
      call add(fns, fn)
    endfor
  " endfor

  " 2- Build the result
  for fn in fns
    let line = s:Overriden(fn).s:Access(fn).' '.fn.fullsignature
          \ . repeat(' ', max_length-lh#encoding#strlen(fn.fullsignature))
          \ . ' ' . string(fn.defined_in)
    call add(a:lines, line)
  endfor
endfunction

" Function: s:BuildMenu(declarations) {{{3
function! s:BuildMenu(declarations) abort
  let res = ['--abort--']
  call s:AddToMenu(res, a:declarations)
  return res
endfunction

" Function: s:Display(className, declarations, api) {{{3
function! s:Display(className, declarations, api) abort
  let choices = s:BuildMenu(a:declarations)
  " return
  let b_id = lh#buffer#dialog#new(
        \ 'override://'.substitute(a:className, '[^A-Za-z0-9_.]', '_', 'g' ),
        \ 'Overrideable functions for '.a:className,
        \ 'bot below',
        \ 1,
        \ { '\<CR\>': 'lh#cpp#override#select', 'd': {l -> lh#cpp#override#select(l, 1)} },
        \ choices
        \)
  call lh#buffer#dialog#add_help(b_id, '@| d                       : override with documentation', 'long')
  call lh#buffer#dialog#add_help(b_id, '@|', 'long')
  call lh#buffer#dialog#add_help(b_id, '@| !==already overridden function in '.a:className, 'long')
  call lh#buffer#dialog#add_help(b_id, '@| +==public, #==protected, -==private in the ancestor class(es)', 'long')
  " Added the lonely functions to the b_id
  let b_id['declarations'] = a:declarations
  let b_id['api']          = a:api
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
function! lh#cpp#override#select(results, ...) abort
  if len(a:results.selection)==1 && a:results.selection[0]==0
    call lh#buffer#dialog#quit()
    return
  endif
  if exists('s:quit') | :quit | endif

  " TODO: use an option
  let should_paste_comment = get(a:, 1, 0)

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
    let api = a:results.dialog.api
    call extend(lines, api.override(selected_virt, should_paste_comment))
  endfor
  " Go back to the original buffer, and insert the built lines
  let where_it_started = a:results.dialog.where_it_started
  call lh#buffer#find(where_it_started[0])
  if 0==append(where_it_started[1]-1, lines)
    silent exe (where_it_started[1]-1).',+'.(len(lines)-1).'normal! =='
    " echo (where_it_started[1]-1).',+'.(len(lines)-1).'normal! =='
  endif
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
