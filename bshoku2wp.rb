#!/usr/bin/env ruby
#
#  bshoku2wp.rb
#
#  Author: Ryosuke KUTSUNA <ryosuke@deer-n-horse.jp>
#

require "./lib/BArticle"
require "./lib/BShoku2WP"

def print_help
  puts "Usage: ruby #{$0} target_dir"
  puts "       target_dir: download directory from b-shoku.jp"
end

def do_export
  files = Dir.glob("#{@target_dir}/article-*.html")
  
  articles = Array.new
  files.each do |f|
    num = File.basename(f).sub("article-","").sub(".html","")
    articles << BArticle.new(num,f)
  end
    
  converter = BShoku2WP.new
  converter.export(articles)
end

@target_dir = ARGV[0]
if @target_dir == nil then
  print_help
  exit
else
  do_export
  exit
end
