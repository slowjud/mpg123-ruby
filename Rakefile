# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'rake/extensiontask'

Hoe.spec 'mpg123_ruby' do
  developer('Jude Sutton', 'jude.sutton@gmail.com')
  spec_extras[:extensions] = "ext/extconf.rb" 
  extra_dev_deps << ['rake-compiler', '>= 0']
  executables = nil
  
  Rake::ExtensionTask.new('mpg123_ruby', spec) do |ext|
    ext.lib_dir = File.join('lib', 'mpg123_ruby')
  end
  # self.rubyforge_name = 'mpg123_rubyx' # if different than 'mpg123_ruby'
end

# vim: syntax=ruby
