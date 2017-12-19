#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
#
#  bshokuback.rb
#

require 'fileutils'
require 'open-uri'
require 'nokogiri'
require 'uconv'

@baseurl="http://www.b-shoku.jp/modules/wordpress/?author="

def print_help
  puts "Usage: $0 UserID Save_Dir"
  puts "       UserID: B食会員番号"
  puts "       Save_Dir: 保存ディレクトリ"
end

def create_output_dir()
  unless Dir.exist?("#{@savedir}/images")
    FileUtils.mkdir_p("#{@savedir}/images")
  end
end

def collectImageFromArticle(file)
  imagesdata = Array.new
  doc = Nokogiri::HTML(Uconv.euctou8(open(file).read),nil,'UTF-8')
  @article = doc.xpath('//div[@class="blog-text-text"]')
  @article.xpath('//img[@class="post_img_design2"]').each do |i|
    imagesdata << i.attribute("src").value
  end
  @article.xpath('//img[@class="post_img_design"]').each do |i|
    imagesdata << i.attribute("src").value
  end
  @article.xpath('//img[@class="post_image"]').each do |i|
    imagesdata << i.attribute("src").value
  end
  return imagesdata
end

def downloadImages(file)
  images = collectImageFromArticle(file)

  # 記事ページ内の画像をダウンロードする。
  images.each do |f|
    savefile = File.basename(f)
    open("#{@savedir}/images/#{savefile}", "wb") do |o|
      open("#{f}") do |d|
        o.write(d.read)
      end
    end
    puts "Download image: #{@savedir}/images/#{savefile}"
  end
end

def downloadArticleHtml(file)
  File.open(file, "r") do |f|
    articles = Array.new
    f.each_line do |l|
      ul = Uconv.euctou8(l) 
      if ul =~ /この記事のURL/
        articles << Nokogiri::HTML(ul).xpath('//a[@href]').text
      end
    end
    
    articles.each do |art|
      num = art.split("&")[1].gsub("p=","")
      open("#{@savedir}/article-#{num}.html", "w") do |o|
        open("#{art}") do |d|
          o.write(d.read)
        end
        puts "Download article: #{@savedir}/article-#{num}.html"
      end
      downloadImages(art)
    end
  end
end

def downloadPageHtml()
  i=1

  while true do
    # ページ単位で最新から最古までダウンロードする。
    open("#{@savedir}/#{i}.html", 'w') do |output|
      open("#{@baseurl}#{@userid}&paged=#{i}") do |d|
        output.write(d.read)
      end
    end
    puts "Download page: #{@baseurl}#{@userid}&paged=#{i} => #{@savedir}/#{i}.html"
  
    ## 記事の無いページまで来たら終了する。
    File.open("#{@savedir}/#{i}.html") do |f|
      f.each_line do |l|
        if Uconv.euctou8(l) =~ /該当する記事はありません/
          puts "Read finished."
          exit 0
        end
      end
    end

    downloadArticleHtml("#{@savedir}/#{i}.html")

    i=i+1
  end
end

### main ###
@userid=ARGV[0]
@savedir=ARGV[1]

state=0
if @userid == nil then
  state=1
end
if @savedir == nil then 
  state=1
end

if state == 1  then
	print_help
	exit 1
end

create_output_dir
downloadPageHtml
