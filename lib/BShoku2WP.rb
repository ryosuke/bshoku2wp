#!/usr/bin/env ruby
#
#  BShoku2WP.rb
#
#  Author: Ryosuke KUTSUNA <ryosuke@deer-n-horse.jp>
#

require 'erb'
require 'uri'
require './config.rb'

class BShoku2WP
  def initialize()
    @image_post_id = 500000
  end

  def export(articles)
    blog_pub_date = Time.new
    $admin_email ||= ""
    $subtitle ||= ""
    $blog_title ||= ""
    $blog_url ||= ""

    puts ERB.new(File.read("erb/header.erb"),nil,"-").result(binding)
    puts ERB.new(File.read("erb/channel-header.erb"),nil,"-").result(binding)
  
    puts ERB.new(File.read("erb/category-nongenre.erb"),nil,"-").result(binding)
    categories = Array.new
    articles.each do |a|
      categories << a.getCategory
    end

    term_id = 1
    categories.sort.uniq.each do |c|
      term_id += 1
      category_urldecode = URI.encode(c)
      category_utf8 = c
      puts ERB.new(File.read("erb/category-genre.erb"),nil,"-").result(binding)
    end

    articles.each do |a|
      article_id = a.getArticleID
      article_title = a.getTitle
      title_urldecode = URI.encode(a.getTitle)
      article_pub_date = a.getPubDate
      category_utf8 = a.getCategory
      category_urldecode = URI.encode(a.getCategory)
      post_date_time = a.getPubDate
      article_content = a.getArticle
      shopinfo = a.getShopInfo
      puts ERB.new(File.read("erb/blog-article.erb"),nil,"-").result(binding)


      comment_id = 1
      a.getComments.each do |c|
        comment_id += 1
        comment_date_time = c.comment_time
        comment_author = c.comment_author
        comment_article = c.comment
        puts ERB.new(File.read("erb/blog-comment.erb"),nil,"-").result(binding)
      end

      puts ERB.new(File.read("erb/blog-article-footer.erb"),nil,"-").result(binding)
      
      a.getImagesData.each do |i|
        image_filename = i
        image_pub_date = a.getPubDate
        @image_post_id += 1
        puts ERB.new(File.read("erb/blog-images.erb"),nil,"-").result(binding)
      end
    end
  
    puts ERB.new(File.read("erb/footer.erb"),nil,"-").result(binding)
  end
end
