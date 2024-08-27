#!/usr/bin/env rake

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :ci => [:dump, :install, :test]

task :default => :spec

task :dump do
  sh 'vim --version'
end

task :test    => :spec

task :spec do
  # 'spec' is implicitly run as well
  # sh 'rspec --require spec_helper'
  sh "bundle exec rspec ~/.vim-flavor/repos/LucHermitte_vim-UT/spec/UT_spec_v2.rb"
end

task :install do
  sh 'cat Flavorfile >> tests/Flavorfile'
  sh 'cd tests && bundle exec vim-flavor install'
end
