"=============================================================================
" $Id$
" File:		mkVba/mk-lh-cpp.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	06th Nov 2007
" Last Update:	$Date$
"------------------------------------------------------------------------
cd <sfile>:p:h
15,$MkVimball! lh-cpp
set modifiable
set buftype=
finish
after/ftplugin/c/c_brackets.vim
after/plugin/a.vim
plugin/a-old.vim
after/template/cpp/internals/stream-common.template
after/template/cpp/internals/stream-implementation.template
after/template/cpp/internals/stream-signature.template
after/template/cpp/bool-operator.template
after/template/cpp/class.template
after/template/cpp/singleton.template
after/template/cpp/stream-extractor.template
after/template/cpp/stream-inserter.template
after/template/cpp/namespace.template
after/template/cpp/author-doxygen.template
after/template/cpp/for-iterator.template
after/template/cpp/fori.template
after/template/cpp/doxygen-function.template
after/template/cpp/file-dox.template
after/template/cpp/utf8.template
autoload/lh/cpp/AnalysisLib_Class.vim
autoload/lh/cpp/AnalysisLib_Function.vim
autoload/lh/cpp/GotoFunctionImpl.vim
autoload/lh/cpp/UnmatchedFunctions.vim
autoload/lh/cpp/file.vim
doc/lh-cpp-readme.txt
doc/c.html
fold/c-fold.vim
fold/cpp-fold.vim
ftplugin/c/c_UnmatchedFunctions.vim
ftplugin/c/c_switch-enum.vim
ftplugin/c/c_doc.vim
ftplugin/c/c_set.vim
ftplugin/c/c_stl.vim
ftplugin/c/flistmaps.vim
ftplugin/c/LoadHeaderFile.vim
ftplugin/c/previewWord.vim
ftplugin/c/word.list
ftplugin/c/c_mu-template_api.vim
ftplugin/cpp/changelog
ftplugin/cpp/cpp_BuildTemplates.vim
ftplugin/cpp/cpp_FindContextClass.vim
ftplugin/cpp/cpp_GotoFunctionImpl.vim
ftplugin/cpp/cpp_InsertAccessors.vim
ftplugin/cpp/cpp_options-commands.vim
ftplugin/cpp/cpp_options.vim
ftplugin/cpp/cpp_set.vim
ftplugin/cpp/cpp_refactor.vim
ftplugin/cpp/cpp_Doxygen_class_stuff.vim
ftplugin/cpp/cpp_Doxygen.vim
ftplugin/cpp/cpp_menu.vim
ftplugin/idl_set.vim
plugin/homeLikeVC++.vim
plugin/omap-param.vim
syntax/c.vim
syntax/cpp.vim
syntax/cpp-badcast.vim
syntax/cpp-funcdef.vim
syntax/c-assign-in-condition.vim
syntax/cpp-throw-spec.vim
tests/lh-cpp-TU.cpp
tests/omap-param.vim
changelog-cpp
