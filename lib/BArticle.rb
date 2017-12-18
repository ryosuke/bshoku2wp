#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
#
#   BArticle.rb
#
#   Author: Ryosuke KUTSUNA <ryosuke@deer-n-horse.jp>
#

require 'nokogiri'
require 'uconv'

class BArticle
  def initialize(b_id, file)
    @b_id = b_id
    parseBFile(file)
  end

  def parseComment(doc)
    comments = Array.new
    n=0
    comtime = nil
    comauthor = nil

    doc.text.lines do |l|
      if l =~ /]$/
        unless l =~ /ページトップ/
          if l =~ /年/
            comtime = l
          end
          unless l =~ /年/
            comauthor = l
          end
        end
      end

      if comtime != nil && comauthor != nil
        com = BArticleComment.new
        com.article_id = @b_id
        com.comment_time = Time.mktime(comtime.scan(/\d+/)[0],
                                       comtime.scan(/\d+/)[1],
                                       comtime.scan(/\d+/)[2],
                                       comtime.scan(/\d+/)[3],
                                       comtime.scan(/\d+/)[4])
        com.comment_author = comauthor.sub("[", "").sub("]","").delete(" ")
        com.comment = doc.xpath('//div[@class="popup-contents-subtitle"]')[n]
        comments << com
        n=n+1

        comtime = nil
        comauthor = nil
      end
    end
    return comments
  end

  def parseBFile(file)
    doc = Nokogiri::HTML(Uconv.euctou8(open(file).read),nil,'UTF-8')
    @title = doc.xpath('//div[@class="blog-title-title"]').text.strip
    @pubDate = Time.mktime(doc.xpath('//div[@class="blog-update"]').text.scan(/\d+/)[0], 
                           doc.xpath('//div[@class="blog-update"]').text.scan(/\d+/)[1],
                           doc.xpath('//div[@class="blog-update"]').text.scan(/\d+/)[2],
                           doc.xpath('//div[@class="blog-update"]').text.scan(/\d+/)[3],
                           doc.xpath('//div[@class="blog-update"]').text.scan(/\d+/)[4])
    @category = doc.xpath('//div[@class="blog-title-time"]/a').text
    @article = doc.xpath('//div[@class="blog-text-text"]')

    @shop = doc.xpath('//table[@border="0"]')[1]

    @imagesdata = Array.new
    # 新しいブログ形式のimgタグ処理(1)
    @article.xpath('//img[@class="post_img_design2"]').each do |i|
      @imagesdata << File.basename(i.attribute("src").value.gsub("http://www.b-shoku.jp/modules","")).gsub(/.JPG$/,".jpg").gsub(/.PNG/, ".png")
      i.attribute("src").value = i.attribute("src").value.gsub(/http:\/\/www.b-shoku.jp\/modules\/wordpress\/attach\/u\d+\//,"/wp-content/uploads/").gsub(/.JPG$/,".jpg").gsub(/.PNG/, ".png")
    end

    # 新しいブログ形式のimgタグ処理(2)
    @article.xpath('//img[@class="post_img_design"]').each do |i|
      @imagesdata << File.basename(i.attribute("src").value.gsub("http://www.b-shoku.jp/modules","")).gsub(/.JPG$/,".jpg").gsub(/.PNG/, ".png")
      i.attribute("src").value = i.attribute("src").value.gsub(/http:\/\/www.b-shoku.jp\/modules\/wordpress\/attach\/u\d+\//,"/wp-content/uploads/").gsub(/.JPG$/,".jpg").gsub(/.PNG/, ".png")
    end
    # 古いブログ形式のimgタグ処理
    @article.xpath('//img[@class="post_image"]').each do |i|
      @imagesdata << File.basename(i.attribute("src").value.gsub("http://www.b-shoku.jp/modules","")).gsub(/.JPG$/,".jpg").gsub(/.PNG/, ".png")
      i.attribute("src").value = i.attribute("src").value.gsub(/http:\/\/www.b-shoku.jp\/modules\/wordpress\/attach\/u\d+\//,"/wp-content/uploads/").gsub(/.JPG$/,".jpg").gsub(/.PNG/, ".png")
    end

    # 絵文字の処理
    @article.xpath('//img').each do |i|
      i.attribute('src').value = i.attribute('src').value.gsub(/http:\/\/www.b-shoku.jp\/modules\/wordpress\/wp-images\/emoji\//,"/wp-content/uploads/emoji-")
    end
    @article.xpath('//img').each do |i|
      i.attribute('src').value = i.attribute('src').value.gsub(/http:\/\/www.b-shoku.jp\/uploads\/\.\.\/modules\/wordpress\/wp-images\/emoji\//,"/wp-content/uploads/emoji-")
    end
    
    @comments = parseComment(doc.xpath('//div[@class="popup-contents"]'))
  end

  # 記事情報の取得
  def getArticleID
    return @b_id
  end

  def getTitle
    return @title
  end

  def getPubDate
    return @pubDate
  end

  def getCategory
    return @category
  end

  # 本文情報の取得
  def getArticle
    return @article
  end

  # コメント情報の取得
  def getComments       # return Array
    return @comments
  end

  # 添付画像情報の取得
  def getImagesData     # return Array
    return @imagesdata
  end

  def getShopInfo
    if @shop == nil
      @shop == ""
    end
    return @shop
  end
end

class BArticleComment
  attr_accessor :article_id, :comment_time, :comment_author, :comment

  def initialize()
    #article_id = id
  end
end

### main ###
if __FILE__ == $0
  target_file = ARGV[0]
  if target_file == nil  then
    exit
  end
  num = File.basename(target_file).sub("article-","").sub(".html","")
  bfile = BArticle.new(num, target_file)

  puts "ID        : #{bfile.getArticleID}"
  puts "Title     : #{bfile.getTitle}"
  puts "pubDate   : #{bfile.getPubDate}"
  puts "Category  : #{bfile.getCategory}"
  puts "Article   : #{bfile.getArticle}"
  puts "Comments  : "
  bfile.getComments.each do |c|
    puts "      ID: #{c.article_id}"
    puts "      Time: #{c.comment_time}"
    puts "      Author: #{c.comment_author}"
    puts "      Comment: #{c.comment}"
    puts " ====================================="
  end
  puts "Images    : "
  bfile.getImagesData.each do |i|
    puts "     #{i}"
  end
end
