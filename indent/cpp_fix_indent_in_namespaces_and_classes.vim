"=============================================================================
" File:         indent/cpp_fix_indent_in_namespaces_and_classes.vim {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/blob/master/License.md>
" Version:      2.2.1.
let s:k_version = '221'
" Created:      16th Jan 2025
" Last Update:  17th Jan 2025
"------------------------------------------------------------------------
" Description:
"       Attempt at fixing indentation of continued lines in namespaces,
"       structs and classes.
"
"       The issue has been described at:
"       - https://vi.stackexchange.com/questions/5853/is-it-possible-to-get-the-rule-cinoptions-that-govern-the-indentation-for-a-sp
"       - https://stackoverflow.com/questions/387792/vim-indentation-for-c-templates
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:
" - Migrate to Vim9 for better performances
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
if !get(g:, 'lhcpp_fix_indent_in_namespace', 1)
  finish
endif

setlocal indentexpr=s:fix_indent(v:lnum)

function! s:fix_indent(lnum) abort
  " The fix: if the direct context is not a function, don't apply cino-+
  " IOW, apply the fix only if the direct context ∉ {namespace, struct,
  " class, enum, union}

  let vanilla_cindent = cindent(a:lnum)

  " First test whether the context is cino-+
  let old_cino = &cinoptions
  try
    setlocal cinoptions=+8s
    let cindent_for_continuation = cindent(a:lnum)
    if cindent_for_continuation == vanilla_cindent
      " cino-+ doesn't apply => fallback to what has been configured with 'cinoptions'
      return vanilla_cindent
    endif

    " Check the exact context
    let context = lh#cpp#AnalysisLib_Class#get_kind_of_direct_englobbing_brackets(a:lnum)
    if !empty(context)
      let &cinoptions = old_cino
      set cinoptions+=+0
      return cindent(a:lnum)
    endif

    " Otherwise, fallback to what has been configured with 'cinoptions'
    return vanilla_cindent
  finally
    let &cinoptions = old_cino
  endtry
endfunction


let b:did_indent = 1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
