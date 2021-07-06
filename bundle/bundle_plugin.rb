#!/usr/bin/ruby

require 'fileutils'
require 'erb'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: bundle_plugin.rb [options]"
  opts.on('-d', '--directory DIR', 'Directory where the files will be copied to') { |v| options[:directory] = v }
end.parse!

if !options[:directory] || options[:directory] == '.'
  target_directory = "."
else
  target_directory = options[:directory]
end
puts "Copy files to '#{target_directory}'"

PLUGIN_DIR = 'redmine_cas'
SOURCE_DIR = '../src'
FileUtils.mkdir_p(File.join(target_directory, PLUGIN_DIR))

files = Dir.entries(SOURCE_DIR)
directories = files.select { |entry| File.directory? File.join(SOURCE_DIR, entry) and !(entry == '.' || entry == '..' || entry == 'test') and !entry.start_with? '.' }
directories.each do |directory|
  FileUtils.cp_r File.join(SOURCE_DIR, directory), File.join(PLUGIN_DIR, directory), :verbose => true
end
FileUtils.cp File.join(SOURCE_DIR, 'Gemfile'), File.join(PLUGIN_DIR, 'Gemfile'), :verbose => true
FileUtils.cp File.join(SOURCE_DIR, 'init.rb'), File.join(PLUGIN_DIR, 'init.rb'), :verbose => true


