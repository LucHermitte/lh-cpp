"=============================================================================
" $Id$
" File:		autoload/lh/cpp/GotoFunctionImpl.vim                      {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
" Created:	07th Oct 2006
" Last Update:	$Date$ (04th Jan 2012)
"------------------------------------------------------------------------
" Description:	
" 	Implementation functions for ftplugin/cpp/cpp_GotoImpl
" 
"------------------------------------------------------------------------
" Installation:	
" 	Drop this file into {rtp}/autoload/lh/cpp/
" 	Use Vim 7+
" History:	
" 	12th Sep 2007:
" 	(*) Accepts spaces between "~" and class name (destructors)
" 	v1.0.0:
" 	(*) Code moved from ftplugin/cpp/cpp_GotoFunctionImpl.vim
" 	(*) Fixes issues with g:alternateSearchPath in order to open the .cpp
" 	in the correct subdirectory
" 	(*) Don't escape '&' (from parameter's type) to build search regex 
"	(*) Preserve line breaks between parameters
"	(*) A message is displayed if the position of the function definition
"	    cannot be found.
"	v1.1.0
"	(*) two functions moved to autoload/lh/cpp/AnalysisLib_Function
"	v1.1.1
"	(*) Support jump to existing destructor
"	(*) Support jump to constructor with a initialization-list
"	(*) Support "using namespace"
"	(*) Don't expect the searched regex to start the line (as the return
"	    type may need to be fully-qualified is the function definition)
"	v2.0.0
"	(*) GPLv3 with exception
"	(*) parameter for the new implementation file extention
"	(*) reuse a know buffer if it already exists -- i.e.: not limited to
"	    readable files
"       (*) facultative option: extension of the file where to put the
"           definition of the function.
"       (*) Fix :GOTOIMPL to work even if &isk contains ":"
" TODO:
" 	(*) add knowledge about C99/C++11 new numeric types
" 	(*) :MOVETOIMPL should not expect the open-brace "{" to be of the same
" 	    line as the function signature.
" 	(*) Check how to convert the return, and the parameters, types to their
" 	    fully-qualified names if required in the function definition.
" }}}1
"=============================================================================


"=============================================================================
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Functions {{{1
" # Debug {{{2
function! lh#cpp#GotoFunctionImpl#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#GotoFunctionImpl#debug(expr)
  return eval(a:expr)
endfunction

" # Public {{{2
"------------------------------------------------------------------------
" Function: lh#cpp#GotoFunctionImpl#MoveImpl() "{{{3
" The default values for 'HowToShowVirtual', 'HowToShowStatic' and
" 'HowToShowDefaultParams' can be overridden momentarily.
" Parameters: None
function! lh#cpp#GotoFunctionImpl#MoveImpl(...)
  try
    let a_save = @a
    let s      = @/

    let [end_proto, proto] = lh#dev#c#function#get_prototype(line('.'), 0, 1)
    if empty(proto)
      throw "No prototype found under the cursor."
    endif
    " move to the start of the definition
    call setpos('.', end_proto) " this puts us one char behind the definition start
    if lh#position#char_at_mark('.') !~ '[:{]'
      normal! h
    endif
    if proto[-1:] == ':'
      " select everything till the open bracket.
      " this won't work with C++11 initialiser-lists extended to {}
      silent exe "normal! \"ad/{\<cr>"
    else
      let @a = ''
    endif
    silent normal! "Ad%
    " For some reason, the previous command insert a trailing newline
    let @a = substitute(@a, '^\_s*', '', '')
    " Add the ';' at the end what precedes, but not on a single line
    call search('\S', 'b')
    silent :exe "normal! A;\<esc>"
    " Search the prototype (once again!), from a compatible position (on the
    " closing bracket)
    call search(')', 'b')
    " For now, search the protype once again...
    :exe "normal! :GOTOIMPL ".join(a:000, ' ')."\<cr>va{\"ap=a{"
    " was:
    " :exe "normal! \<home>f{\"ac%;\<esc>:GOTOIMPL ".join(a:000, ' ')."\<cr>va{\"ap=a{"
  finally
    let @a = a_save
    let @/ = s
  endtry
endfunction

"------------------------------------------------------------------------
" Function: lh#cpp#GotoFunctionImpl#GrabFromHeaderPasteInSource "{{{3
" The default values for 'HowToShowVirtual', 'HowToShowStatic' and
" 'HowToShowDefaultParams' can be overridden momentarily.
" Parameters: 'ShowVirtualon', 'ShowVirtualoff', 'ShowVirtual0', 'ShowVirtual1',
" 	      'ShowStaticon', '..off', '..0' or '..1'
" 	      'ShowExplicitcon', '..off', '..0' or '..1'
" 	      'ShowDefaultParamson', '..off', '..0', '..1',  or '..2'
" TODO: add C++11 override and final
let s:option_value = '\%(on\|off\|\d\+\)$'
function! lh#cpp#GotoFunctionImpl#GrabFromHeaderPasteInSource(...)
  let expected_extension = call('s:CheckOptions', a:000)

  " 1- Retrieve the context {{{4
  " 1.1- Get the class name,if any -- thanks to cpp_FindContextClass.vim
  let className = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'), '##')
  " 1.2- Get the whole prototype of the function (even if on several lines)
  let proto = lh#cpp#AnalysisLib_Function#GetFunctionPrototype(line('.'), 1)
  if "" == proto
    call lh#common#error_msg('cpp#GotoFunctionImpl.vim: We are not uppon the declaration of a function prototype!')
    return
  endif

  " 2- Build the result strings {{{4
  try
    let isk_save = &isk
    set isk-=: 
    let impl2search = s:BuildRegexFromImpl(proto,className)
    if impl2search.ispure
      call lh#common#error_msg("cpp#GotoFunctionImpl.vim:\n\n".
            \ "Pure virtual functions don't have an implementation!")
      return
    endif

    " 3- Add the string into the implementation file {{{4
    call lh#cpp#GotoFunctionImpl#open_cpp_file(expected_extension)
    " Search or insert the C++ implementation
    if !s:Search4Impl((impl2search.regex).'\_s*[{:]', className)
      let impl        = s:BuildFunctionSignature4impl(proto,className)
      " Todo: Support looking into other files like the .inl file

      " Insert the C++ code at the end of the file
      call lh#cpp#GotoFunctionImpl#insert_impl(impl)
    endif
  finally
    let &isk = isk_save
  endtry

  " call confirm(impl, '&ok', 1)
  " }}}4
endfunction 

"------------------------------------------------------------------------
" Function: lh#cpp#GotoFunctionImpl#insert_impl(impl) {{{3
function! lh#cpp#GotoFunctionImpl#insert_impl(impl)
  let p = s:SearchLineToAddImpl()
  if -1 != p
    call s:InsertCodeAtLine(a:impl, p)
    let s:FunctionImpl = a:impl
  else
    " Otherwise, we use a method somehow like the one used by Robert:
    " We store the text to insert in a specific variable and wait for manual
    " insertion of the text.
    let s:FunctionImpl = a:impl
    call lh#common#warning_msg(":GOTOIMPL cannot determine where the function definition should be inserted."
	  \ ."\nUse :PASTEIMPL to paste the code prepared."
	  \ ."\nSee ftplugin/cpp/cpp_options.vim to tune the placement heuristic")
  endif
endfunction

"------------------------------------------------------------------------
" Function: lh#cpp#GotoFunctionImpl#open_cpp_file(expected_extension) {{{3
function! lh#cpp#GotoFunctionImpl#open_cpp_file(expected_extension)
  if expand('%:e') =~? 'cpp\|c\|C\|cxx'
    " already within the .cpp file
    return 
  endif
  try 
    " neutralize mu-template jump to marker feature {{{5
    if exists('g:mu_template') && 
          \ (!exists('g:mt_jump_to_first_markers') || g:mt_jump_to_first_markers)
      " NB: g:mt_jump_to_first_markers is true by default
      let mt_jump = 1
      let g:mt_jump_to_first_markers = 0
    endif " }}}4
    let split_opt = ''
    let use_alternate = 1
    if !empty(a:expected_extension)
      let split_opt = NewAlternateFilename(expand('%:p'), a:expected_extension)
      let split_opt = lh#path#to_relative(split_opt)
      let use_alternate = 0
    elseif exists(':AS') " from a.vim
      if !s:IsThereAMatchingSourceFile(expand('%:p'))
        let split_opt = NewAlternateFilename(expand('%:p'), a:expected_extension)
        let split_opt = lh#path#to_relative(split_opt)
        let use_alternate = 0
      endif
    else
      let root_name = fnamemodify(expand('%'), ':r')
      let best_ext = s:BestExtensionFor(root_name, a:expected_extension)
      let split_opt = root_name . '.' . best_ext
      let use_alternate = 0
    endif
    call s:DoSplit(split_opt, use_alternate)
  finally
    " restore mu-template " {{{5
    if exists('mt_jump')
      let g:mt_jump_to_first_markers = mt_jump
    endif " }}} 4
  endtry
endfunction

" # Private {{{2

function! s:CheckOptions(...)
  " 0- Check options {{{4
  let s:ShowVirtual		= lh#dev#option#get('ShowVirtual',       &ft, 1)
  let s:ShowStatic		= lh#dev#option#get('ShowStatic',        &ft, 1)
  let s:ShowExplicit		= lh#dev#option#get('ShowExplicit',      &ft, 1)
  let s:ShowDefaultParams	= lh#dev#option#get('ShowDefaultParams', &ft, 1)
  let expected_extension        = ''
  if 0 != a:0
    let i = 0
    while i < a:0
      let i +=  1
      let varname = substitute(a:{i}, '\(.*\)'.s:option_value, '\1', '') 
      if varname !~ 'ShowVirtual\|ShowStatic\|ShowExplicit\|ShowDefaultParams' " Error {{{5
        if !empty(expected_extension)
          call lh#common#error_msg(
                \ 'cpp#GotoFunctionImpl.vim::GrabFromHeaderPasteInSource: extension already set to <'.expected_extension.'>')
          return
        else
          let expected_extension = a:{i}
        endif
      else " }}}4
        let val = matchstr(a:{i}, s:option_value)
        if     val == 'on'  | let val = 1
        elseif val == 'off' | let val = 0
        elseif val !~ '\d\+'
          call lh#common#error_msg(
                \ 'cpp#GotoFunctionImpl.vim::GrabFromHeaderPasteInSource: Invalid value for parameter : <'.varname.'>')
          return
        endif
        " exe "let s:".varname."= val"
        let s:{varname} = val
        " call confirm(s:{varname}.'='.val, '&ok', 1)
      endif
    endwhile
  endif
  return expected_extension
endfunction
"------------------------------------------------------------------------
" Function: s:BestExtensionFor(root_name) {{{3
function! s:BestExtensionFor(root_name, expected_extension)
  if !empty(a:expected_extension) | return a:expected_extension | endif
  let Best_ext = lh#dev#option#get('ext_4_impl_file', &ft, 'cpp')
  let best_ext = type(Best_ext) == type(function('has'))
        \ ?  Best_ext(a:root_name)
        \ : Best_ext
  return best_ext
endfunction

"------------------------------------------------------------------------
" Function: s:BuildRegexFromImpl(impl,className) {{{3
" Build the regex that will be used to search the signature in the
" implementations file
function! s:BuildRegexFromImpl(impl,className)
  let impl2search=lh#cpp#AnalysisLib_Function#SignatureToSearchRegex(a:impl,a:className)
  let g:impl2search2 = impl2search
  return impl2search
  " }}}4
endfunction
"------------------------------------------------------------------------
" Function: s:Search4Impl(re_impl, scope):bool {{{3
function! s:Search4Impl(re_impl, scope)
  " 0- Pretransformations {{{4
  let required_ns = matchstr(a:scope, '^.*\ze#::#')
  " 1- Memorize position {{{4
  let l0 = line('.')
  " 2- Loop until the implementation is found, {{{4
  "    *and* the scope (namespaces) matches
  normal! gg
  " let l = 1
  while 1 " l > 0
    " a- search for an acceptable implementation {{{5
    "    Note: re_impl looks like :
    "    'type \(\(ns1::\)\=ns2::\)\=cl1::cl2::function(...)'
    let l = search(a:re_impl, 'W')
    if l <= 0 | break | endif

    " b- Get the current namespace at the found line {{{5
    let current_ns = lh#cpp#AnalysisLib_Class#CurrentScope(l, 'namespace')
    let imported_ns = lh#cpp#AnalysisLib_Class#used_namespaces(l)
    let ns_list = imported_ns + [current_ns]

    " c- Build the function name that must be found on the current line {{{5
    "    The function aname also contain the scope
    " let req_proto  = matchstr(required_ns, current_ns.
    " \ (current_ns == '') ? '.*$' : '::\zs.*$')

    " d- Retrieve the actual function name (+ relative scope) {{{5
    let z=@"
    let fe=&foldenable
    set nofoldenable
    let mv = l."gg".virtcol('.').'|'
    if search('(', 'W') <= 0 
      " echoerr "Weird Error!!!" 
    endif
    silent exe 'normal! v'.mv.'y'
    let &foldenable=fe
    let current_proto = matchstr(@", '\%(::\|\<\I\i*\>\|\~\)\+\ze($')
    let proto0= @"
    let @" = z
    " Todo: purge comments within current_proto

    " e- Check if really found {{{5
    for ns in ns_list
      " if match(required_ns, '^'.ns) == 0 
      " \ && (req_proto == current_proto)
      let current = ns . ((ns != "") ? '::' : '' ).current_proto
      if ("" != required_ns) && (required_ns !~ '.*::$')
        let required_ns .=  '::' 
      endif
      " call confirm('required_ns='.required_ns.
      " \ "\ncurrent_proto=".current_proto.
      " \ "\ncurrent_ns=".ns.
      " \ "\n".l."=".getline('.').
      " \ "\n\nmv=".mv."\nproto0=".proto0."\ncurrent=".current,
      " \ '&ok', 1)
      " \ "\n\nreq_proto=".req_proto.
      if match(current,'^'.required_ns) == 0 
        return l 
      endif
    endfor
    " }}}5
  endwhile

  " 2.b- Not found {{{4
  exe l0
  return 0
  " }}}4
endfunction
"------------------------------------------------------------------------
" Function: s:BuildFunctionSignature4impl " {{{3
let s:k_operators = '\<operator\%([=~%+-\*/^&|]\|[]\|()\|&&\|||\|->\|<<\|>>\)'
function! s:BuildFunctionSignature4impl(proto,className)
  let proto = lh#cpp#AnalysisLib_Function#AnalysePrototype(a:proto)
  let g:implproto = proto

  let re_qualifiers = []
  " 1.a- XXX if you want virtual commented in the implementation: {{{4
  if s:ShowVirtual
    let re_qualifiers += ['\<virtual\>']
  endif

  " 1.b- XXX if you want static commented in the implementation: {{{4
  if s:ShowStatic
    let re_qualifiers += ['\<static\>']
  endif

  " 1.b- XXX if you want explicit commented in the implementation: {{{4
  if s:ShowExplicit
    let re_qualifiers += ['\<explicit\>']
  endif
  let comments = matchstr(proto.qualifier, join(re_qualifiers, '\|'))
  if !empty(comments)
    let comments = '/*'.comments.'*/ ' 
  endif

  " 2- Handle default params, if any. {{{4
  "    0 -> ""              : ignored
  "    1 -> "/* = value */" : commented
  "    2 -> "/*=value*/"    : commented, spaces trimmed
  "    3 -> "/*value*/"     : commented, spaces trimmed, no equal sign
  if     s:ShowDefaultParams == 0 | let pattern = '\2'
  elseif s:ShowDefaultParams == 1 | let pattern = '/* = \1 */\2' 
  elseif s:ShowDefaultParams == 2 | let pattern = '/*=\1*/\2'
  elseif s:ShowDefaultParams == 3 | let pattern = '/*\1*/\2'
  else                            | let pattern = '\2'
  endif
  "

  let implParams = []
  for param in proto.parameters
    " TODO: param type may need to be fully-qualified, see 4.2
    let sParam = ((param.nl) ? "\n" : '')
	  \ . (param.type) . ' ' . (param.name) 
	  \ . substitute((param.default), '\(.\+\)', pattern, '')
    " echo "param=".param
    call add(implParams, sParam)
  endfor
  let implParamsStr = join(implParams, ', ')
  " @todo: exceptions specifications

  " 3- Add '::' to the class name (if any).{{{4
  let className = a:className . (""!=a:className ? '::' : '')
  " let impl = substitute(impl, '\%(\~\s*\)\=\%(\<\i\+\>\|'.s:k_operators.'\)\('."\n".'\|\s\)*(', 
  " \ className.'\0', '')

  " 4- Add scope to other types {{{4
  try
    let ltags = lh#dev#start_tag_session()
    " 4.1- ... return type
    let all_ret_dicts = filter(copy(ltags), 'v:val.name == '.string(proto.return))
    let all_rets = lh#list#transform(all_ret_dicts, [], 'v:1_.class')
    let all_rets = lh#list#unique_sort(all_rets)
    if len(all_rets) > 1
      let all_rets = ['::'] + all_rets
      let choice = CONFIRM('Where does <'.(proto.return).'> comes from?',
            \ join(all_rets, "\n"), 1)
      if     choice == 0 | let scope = []
      elseif choice == 1 | let scope = ['']
      else               | let scope = [all_rets[choice-1]]
      endif
    elseif len(all_rets) == 1
      let scope = all_rets
    else
      let scope = []
    endif
    let scope += [proto.return]
    let return = join(scope, '::')
    " 4.2- ... parameters types
  finally
    call lh#dev#end_tag_session()
  endtry

  " 5- Return{{{4
  " TODO: some styles like to put return types and function names on two
  " different lines
  let res = comments
        \ . return . ' '
        \ . className
        \ . join(proto.name, '::')
        \ . '('.implParamsStr . ')'
        \ . (proto.const ? ' const' : '')
        \ . (!empty(proto.throw) ? ' throw ('.join(proto.throw, ',').')' : '')
        \ . "\n{\n}"
  return res
  "}}}4
endfunction
"------------------------------------------------------------------------
" Function: s:SearchLineToAddImpl() {{{3

function! s:SearchLineToAddImpl()
  let cpp_FunctionPosition = lh#dev#option#get('FunctionPosition', &ft, 'g', 0)
  let cpp_FunctionPosArg   = lh#dev#option#get('FunctionPosArg',   &ft, 'g', 0)
  if     cpp_FunctionPosition == 0 " {{{4
    return line('$') + cpp_FunctionPosArg
  elseif cpp_FunctionPosition == 1 " {{{4
    if !exists('g:cpp_FunctionPosArg') 
      call lh#common#error_msg('cpp#GotoFunctionImpl.vim: The search pattern '.
	    \'<g:cpp_FunctionPosArg> is not defined')
      return -1
    endif
    let s=search(g:cpp_FunctionPosArg)
    if 0 == s
      call lh#common#error_msg("cpp#GotoFunctionImpl.vim: Can't find the pattern\n".
	    \'   <g:cpp_FunctionPosArg>: '.g:cpp_FunctionPosArg)
      return -1
    else
      return s
    endif
  elseif cpp_FunctionPosition == 2 " {{{4
    if     !exists('g:cpp_FunctionPosArg') 
      call lh#common#error_msg('cpp#GotoFunctionImpl.vim: No positionning '.
	    \ 'function defined thanks to <g:cpp_FunctionPosArg>')
      return -1
    elseif !exists('*'.g:cpp_FunctionPosArg) 
      call lh#common#error_msg('cpp#GotoFunctionImpl.vim: The function '.
	    \ '<g:cpp_FunctionPosArg> is not defined')
      return -1
    endif
    exe "return ".g:cpp_FunctionPosArg."()"
    " }}}4
  elseif cpp_FunctionPosition == 3 | return -1
  endif
endfunction
"------------------------------------------------------------------------
" Function: s:InsertCodeAtLine([code [,line]]) {{{3
function! s:InsertCodeAtLine(...)
  if     a:0 >= 2 | let p = a:2+1     | let impl = a:1
  elseif a:0 >= 1 | let p = line('.') | let impl = a:1
  else            | let p = line('.') | let impl = s:FunctionImpl
  endif
  " Check namespace value
  let ns = lh#cpp#AnalysisLib_Class#CurrentScope(p, 'namespace')
  let ns0 = ns
  let impl0 = impl
  " call confirm('ns  ='.ns."\nimpl=".impl, '&Ok', 1)
  while ns != ""
    let n0 = matchstr(ns, '^.\{-}\ze\%(::\|$\)')
    if impl =~ '\s'.n0.'\%(::\|#::#\)'
      " call confirm('trim: '.n0, '&OK', 1)
      let impl = substitute(impl, '\(\s\)'.n0.'\%(::\|#::#\)', '\1', 'g')
    else
      call lh#common#error_msg( 'cpp#GotoFunctionImpl.vim: Namespaces mismatch!!!'.
	    \ "\n\nCan't insert <".
	    \ matchstr(impl0, '\%(::\|#::#\|\<\I\i*\>\)*\ze\_s*(').
	    \ '> within the namespace <'.ns.'>')
      " let g:impl0=impl0
      return 
    endif
    let ns = matchstr(ns, '::\zs.*$')
    " call confirm('ns  ='.ns."\nimpl=".impl, '&Ok', 1)
  endwhile
  " Change my namespace delimiters (#::#) to normal scope delimiters (::)
  let impl = substitute(impl, '#::#', '::', '') . "\n\n"
  " Unfold folders otherwise there could be side effects with ':put'
  let folder=&foldenable
  set nofoldenable
  " Insert the default function implementation at position 'p'
  if p > line('$')
    if getline('$') !~ '^\s*$'
      let impl="\n".impl
    endif
    let p=line('$')
  endif
  silent exe p."put=impl"
  " Note: unlike 'put', 'append' can't insert multiple lines.
  " call append(p, impl)
  " Reindent the newly inserted lines
  let nl = strlen(substitute(impl, "[^\n]", '', 'g')) - 1 
  let p +=  1
  silent exe p.','.(p+nl).'v/^$/normal! =='
  " Restore folding
  let &foldenable=folder
endfunction
"------------------------------------------------------------------------
" Function: NewAlternateFilename(file, expected_extension) {{{3
function! NewAlternateFilename(file, expected_extension)
  " Assert(exists('g:alternateSearchPath') && strlen(g:alternateSearchPath)>0)
  "
  try
    " echomsg a:file
    let extension   = DetermineExtension(fnamemodify(a:file, ":p"))
    let baseName    = substitute(fnamemodify(a:file, ":t"), "\." . extension . '$', "", "")
    let currentPath = fnamemodify(a:file, ":p:h")
    " This is a C++ ft-plugin, not a C ft-plugin!
    if exists('g:alternateExtensions_'.extension)
      let l:save_extensions_h = g:alternateExtensions_{extension}
    endif
    let g:alternateExtensions_{extension} = s:BestExtensionFor(baseName, a:expected_extension)
    let sFiles = EnumerateFilesByExtensionInPath(baseName, extension, g:alternateSearchPath, currentPath)
    let lFiles = split(sFiles, ',')
    " call filter(lFiles, 'v:val != a:file')
    let result = lh#path#select_one(lFiles, "What should be the name of the new file?")
  finally
    " restore
    if exists('l:save_extensions_h')
      let g:alternateExtensions_{extension} = l:save_extensions_h
    else
      unlet g:alternateExtensions_{extension}
    endif
  endtry
  return result
endfunction

" Function: s:IsThereAMatchingSourceFile(file) {{{3
" Check if the file already exists and can be found into the list of
" directories from g:alternateSearchPath.
" This function is a partial workaround for a bug in a.vim:  ":AS cpp" does not
" use g:alternateSearchPath while ":AS" does.
"
function! s:IsThereAMatchingSourceFile(file)
  " DetermineExtension, EnumerateFilesByExtension and
  " EnumerateFilesByExtensionInPath come from a.vim
  let extension   = DetermineExtension(fnamemodify(a:file, ":p"))
  let baseName    = substitute(fnamemodify(a:file, ":t"), "\." . extension . '$', "", "")
  let currentPath = fnamemodify(a:file, ":p:h")
  let allfiles1 = EnumerateFilesByExtension(currentPath, baseName, extension)
  let allfiles2 = EnumerateFilesByExtensionInPath(baseName, extension, g:alternateSearchPath, currentPath)

  " echomsg allfiles1
  " echomsg '---'
  " echomsg allfiles2

  let comma = strlen(allfiles1) && strlen(allfiles2)
  let allfiles = allfiles1 . (comma ? ',' : '') . allfiles2

  let l_allfiles = split(allfiles, ',')
  let l_matches  = filter(l_allfiles, 'filereadable(v:val) || bufexists(v:val)')
  let matches    = join(l_matches, ',')
  return strlen(matches) > 0
endfunction
"------------------------------------------------------------------------
" Split Options: {{{3
" Function: s:SplitOption() {{{4
" @return the type of split desired: "n)o split", "v)ertical" (default one) or
"         "h)orizontal"/
function! s:SplitOption()
  if exists('g:cpp_Split')
    if     g:cpp_Split =~ 'v\%[ertical]'   | return 'v'
    elseif g:cpp_Split =~ 'h\%[orizontal]' | return 'h'
    else                                   | return 'n'
    endif
  endif
  " default: vertical split
  return 'v'
endfunction

" Internal constants {{{4
" s:split_{a.vim or vim built-in commands}_{split n/h/v} = command to execute
" --a.vim
let s:split_a_n = 'A'
let s:split_a_h = 'AS'
let s:split_a_v = 'AV'

" --no a.vim
" @todo don't split if the buffer is opened (while the file does not exists
" yet)
let s:split_n_n = 'e'
let s:split_n_h = 'sp'
let s:split_n_v = 'vsp'

" Function: s:DoSplit(arg) {{{4
function! s:DoSplit(arg, use_alternate)
  if a:use_alternate
    exe 'silent '.s:split_{'a'}_{s:SplitOption()}.' '.a:arg
  else
    call lh#buffer#jump(a:arg, s:split_{'n'}_{s:SplitOption()})
  endif
  " let a = (a:use_alternate ? 'a' : 'n')
  " exe 'silent '.s:split_{a}_{s:SplitOption()}.' '.a:arg
endfunction
" }}}2


" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
