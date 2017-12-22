#!/usr/bin/env ruby
#
#  bshoku2wp.rb
#
#  Author: Ryosuke KUTSUNA <ryosuke@deer-n-horse.jp>
#

require "./lib/BArticle"
require "./lib/BShoku2WP"
require 'optparse'

def print_help
  puts "Usage: ruby #{$0} <option>"
  puts "   -d read_dir: download directory from b-shoku.jp"
  puts "   -o [all,text,image,category]"
end

def do_export(type)
  files = Dir.glob("#{@target_dir}/article-*.html")
  
  articles = Array.new
  files.each do |f|
    num = File.basename(f).sub("article-","").sub(".html","")
    articles << BArticle.new(num,f)
  end
    
  converter = BShoku2WP.new
  converter.export(articles, type)
end

params = ARGV.getopts('o:', 'd:')
@target_dir = params['d']
outputtype = ""
case params['o']
when "all" then
  outputtype = "all"
when "text" then
  outputtype = "text"
when "image" then
  outputtype = "image"
when "category" then
  outputtype = "category"
else
  print_help
  exit
end

if @target_dir == nil then
  print_help
  exit
else
  do_export(outputtype)
  exit
end
