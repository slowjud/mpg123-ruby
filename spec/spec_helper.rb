# mpg123_ruby/spec/spec_helper.rb

SPEC_DIR = File.dirname(__FILE__)
lib_path = File.expand_path("#{SPEC_DIR}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

ext_path = File.expand_path("#{SPEC_DIR}/../ext")
$LOAD_PATH.unshift ext_path unless $LOAD_PATH.include?(ext_path)

require 'mpg123_ruby'