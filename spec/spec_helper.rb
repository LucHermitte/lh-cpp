require 'tmpdir'
require 'vimrunner'
require 'vimrunner/rspec'
require 'support/vim'
require 'rspec/expectations'
require 'support/vim_matchers'
# require 'simplecov'

# SimpleCov.start

module Vimrunner
  class Client
    def runtime(script)
        script_path = Path.new(script)
        command("runtime #{script_path}")
    end
  end
end


Vimrunner::RSpec.configure do |config|
  config.reuse_server = true

  vim_plugin_path = File.expand_path('.')
  vim_flavor_path = ENV['HOME']+'/.vim/flavors'

  config.start_vim do
    vim = Vimrunner.start_gvim
    # vim = Vimrunner.start
    
    vim.add_plugin(vim_flavor_path, 'bootstrap.vim')
    vim.prepend_runtimepath(vim_plugin_path+'/after')
    vim.prepend_runtimepath(vim_plugin_path)

    # lh-UT
    vim_UT_path      = File.expand_path('../../../vim-UT', __FILE__)
    vim.prepend_runtimepath(vim_UT_path)
    vim.runtime('plugin/UT.vim')

    # pp vim_flavor_path
    # lh-vim-lib
    vim_lib_path      = File.expand_path('../../../lh-vim-lib', __FILE__)
    vim.prepend_runtimepath(vim_lib_path)
    vim.runtime('plugin/let.vim') # LetIfUndef
    # vim.runtime('plugin/ui-functions.vim') # lh#ui#confirm
    # vim.command(':messages')

    # lh-dev
    vim_dev_path = File.expand_path('../../../lh-dev', __FILE__)
    vim.prepend_runtimepath(vim_dev_path)
    vim.runtime('plugin/dev.vim') # AddStyle

    # lh-brackets
    vim_brackets_path = File.expand_path('../../../lh-brackets', __FILE__)
    vim.prepend_runtimepath(vim_brackets_path)
    vim.runtime('plugin/misc_map.vim') # Inoreab
    vim.runtime('plugin/common_brackets.vim') # Brackets
    vim.runtime('plugin/bracketing.base.vim') # !mark!
    vim.command('set enc=utf-8')
    #vim.command('SetMarker <+ +>')

    # mu-template
    mu_template_path = File.expand_path('../../../mu-template@lh', __FILE__)
    vim.prepend_runtimepath(mu_template_path+'/after')
    vim.prepend_runtimepath(mu_template_path)
    vim.runtime('plugin/mu-template.vim') # !mark!

    # pp vim.echo('&rtp')
    vim.command('set shm=')

    has_redo = vim.echo('has("patch-7.4.849")')
    if has_redo != "1"
      puts "WARNING: this flavor of vim won't permit to support redo"
    end
    vim
  end
end

RSpec.configure do |config|
  config.include Support::Vim

  def write_file(filename, contents)
    dirname = File.dirname(filename)
    FileUtils.mkdir_p dirname if not File.directory?(dirname)

    File.open(filename, 'w') { |f| f.write(contents) }
  end
end

# vim:set sw=2:
