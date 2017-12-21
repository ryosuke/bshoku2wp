#!/usr/bin/env ruby
#
# imgdownload.rb
#

require 'open-uri'
require 'nokogiri'
require 'uconv'

def parseBFile(file)
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
  @article.xpath('//img').each do |i|
    unless i.attribute("src").value =~ /[dummy,howto,c_shoku_blog_banner].gif/
      imagesdata << i.attribute("src").value
    end
  end

  return imagesdata.sort.uniq
end

def downloadImages(images, savedir)
  images.each do |f|
    savefile = File.basename(f)
    open("#{savedir}/images/#{savefile}", "wb") do |o|
      open("#{f}") do |d|
        o.write(d.read)
      end
    end
    puts "Save: #{savedir}/images/#{savefile}"
  end
end

savedir = ARGV[0]
bfile = ARGV[1]
if bfile == nil
  puts "bfile not exist."
  exit 1
end

if savedir == nil
  puts "savedir not exist."
  exit 1
end

unless Dir.exist?(savedir)
    Dir.mkdir(savedir)
end
unless Dir.exist?("#{savedir}/images")
    Dir.mkdir("#{savedir}/images")
end

images = parseBFile(bfile)
downloadImages(images, savedir)
