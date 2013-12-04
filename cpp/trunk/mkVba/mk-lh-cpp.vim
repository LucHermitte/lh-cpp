"=============================================================================
" $Id$
" File:		mkVba/mk-lh-cpp.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0b4
" Created:	06th Nov 2007
" Last Update:	$Date$
"------------------------------------------------------------------------
let s:version = '2.0.0b4'
let s:project = 'lh-cpp'
cd <sfile>:p:h
try 
  let save_rtp = &rtp
  let &rtp = expand('<sfile>:p:h:h').','.&rtp
  exe '23,$MkVimball! '.s:project.'-'.s:version
  set modifiable
  set buftype=
finally
  let &rtp = save_rtp
endtry
finish
after/ftplugin/c/c_brackets.vim
after/plugin/a.vim
after/template/c/realloc.template
after/template/cpp/abs-rel.template
after/template/cpp/assignment-operator.template
after/template/cpp/b-e.template
after/template/cpp/bool-operator.template
after/template/cpp/catch.template
after/template/cpp/class.template
after/template/cpp/copy-and-swap.template
after/template/cpp/copy-constructor.template
after/template/cpp/default-constructor.template
after/template/cpp/destructor.template
after/template/cpp/enum.template
after/template/cpp/enum2.template
after/template/cpp/erase-remove.template
after/template/cpp/for-enum.template
after/template/cpp/for-iterator.template
after/template/cpp/fori.template
after/template/cpp/foriN.template
after/template/cpp/internals/abs-rel-shared.template
after/template/cpp/internals/formatted-comment.template
after/template/cpp/internals/function-comment.template
after/template/cpp/internals/stream-common.template
after/template/cpp/internals/stream-implementation.template
after/template/cpp/internals/stream-signature.template
after/template/cpp/iss.template
after/template/cpp/namespace.template
after/template/cpp/operator-binary.template
after/template/cpp/oss.template
after/template/cpp/singleton.template
after/template/cpp/stream-extractor.template
after/template/cpp/stream-inserter.template
after/template/cpp/throw.template
after/template/cpp/traits.template
after/template/cpp/try.template
after/template/cpp/utf8.template
after/template/cpp/while-getline.template
after/template/dox/author.template
after/template/dox/code.template
after/template/dox/em.template
after/template/dox/file.template
after/template/dox/function.template
after/template/dox/group.template
after/template/dox/html.template
after/template/dox/tt.template
autoload/lh/cpp/AnalysisLib_Class.vim
autoload/lh/cpp/AnalysisLib_Function.vim
autoload/lh/cpp/GotoFunctionImpl.vim
autoload/lh/cpp/UnmatchedFunctions.vim
autoload/lh/cpp/abs_rel.vim
autoload/lh/cpp/brackets.vim
autoload/lh/cpp/constructors.vim
autoload/lh/cpp/enum.vim
autoload/lh/cpp/ftplugin.vim
autoload/lh/cpp/option.vim
autoload/lh/cpp/override.vim
autoload/lh/cpp/style.vim
autoload/lh/dox.vim
doc/c.html
doc/lh-cpp-readme.txt
fold/c-fold.vim
fold/cpp-fold.vim
ftplugin/c/LoadHeaderFile.vim
ftplugin/c/c_AddInclude.vim
ftplugin/c/c_UnmatchedFunctions.vim
ftplugin/c/c_complete_include.vim
ftplugin/c/c_doc.vim
ftplugin/c/c_gcov.vim
ftplugin/c/c_localleader.vim
ftplugin/c/c_menu.vim
ftplugin/c/c_mu-template_api.vim
ftplugin/c/c_navigate_functions.vim
ftplugin/c/c_set.vim
ftplugin/c/c_snippets.vim
ftplugin/c/c_stl.vim
ftplugin/c/c_switch-enum.vim
ftplugin/c/flistmaps.vim
ftplugin/c/previewWord.vim
ftplugin/c/word.list
ftplugin/cpp/cpp_BuildTemplates.vim
ftplugin/cpp/cpp_Constructor.vim
ftplugin/cpp/cpp_Doxygen.vim
ftplugin/cpp/cpp_Doxygen_class_stuff.vim
ftplugin/cpp/cpp_FindContextClass.vim
ftplugin/cpp/cpp_GotoFunctionImpl.vim
ftplugin/cpp/cpp_InsertAccessors.vim
ftplugin/cpp/cpp_Inspect.vim
ftplugin/cpp/cpp_Override.vim
ftplugin/cpp/cpp_options-commands.vim
ftplugin/cpp/cpp_options.vim
ftplugin/cpp/cpp_refactor.vim
ftplugin/cpp/cpp_set.vim
ftplugin/cpp/cpp_snippets.vim
ftplugin/idl_set.vim
lh-cpp-addon-info.txt
lh-cpp.README
mkVba/mk-lh-cpp.vim
plugin/a-old.vim
plugin/homeLikeVC++.vim
plugin/omap-param.vim
syntax/c-assign-in-condition.vim
syntax/c.vim
syntax/cpp-badcast.vim
syntax/cpp-cxxtest.vim
syntax/cpp-funcdef.vim
syntax/cpp-throw-spec.vim
syntax/cpp.vim
