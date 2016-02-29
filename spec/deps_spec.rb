# encoding: UTF-8
require 'spec_helper'
require 'pp'


RSpec.describe "C++ check dependencies are loaded", :cpp, :deps do
  let (:filename) { "test.cpp" }

  before :each do
    # expect(vim.echo('&enc')).to eq 'utf-8'
    # vim.command('let b:marker_open = "\u00AB"')
    # vim.command('let b:marker_close = "\u00BB"')
    # expect(vim.echo('b:marker_open')).to eq '«'
    # expect(vim.echo('lh#marker#open()')).to eq '«'
    vim.command('filetype plugin on')
    vim.command("file #{filename}")
    vim.set('ft=cpp')
    vim.set('expandtab')
    vim.set('sw=4')
    vim.command('silent! unlet g:cpp_explicit_default')
    vim.command('silent! unlet g:cpp_std_flavour')
    clear_buffer
  end

  it "has loaded C++ ftplugin" do
    # pp vim.echo('&rtp')
    # pp vim.command(':scriptnames')
    expect(/plugin.mu-template\.vim/).to be_sourced
    # expect(/ftplugin.cpp.cpp_snippets\.vim/).to be_sourced
    vim.command('call lh#mut#dirs#update()')
    expect(vim.echo('g:lh#mut#dirs#cache')).to match(/cpp/)
    # pp vim.echo('g:lh#mut#dirs#cache')

    expect(vim.echo('lh#dev#naming#type("toto")')).to eq "Toto"
  end

end
