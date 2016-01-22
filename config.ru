$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'rubygems/package'
require 'bundler/setup'
Bundler.require(:default, :ui)
load 'environment.rb'

require 'ui'
run Uphold::Ui
