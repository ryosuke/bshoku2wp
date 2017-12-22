#!/usr/bin/env ruby
#
# imgrelocate.rb imgdir article_file [d]
#

require 'nokogiri'
require 'uconv'
require 'fileutils'
require 'date'

def parseBFile(file)
  imagesdata = Array.new
  doc = Nokogiri::HTML(Uconv.euctou8(open(file).read),nil,'UTF-8')
  @pubDate = Time.mktime(doc.xpath('//div[@class="blog-update"]').text.scan(/\d+/)[0],
                         doc.xpath('//div[@class="blog-update"]').text.scan(/\d+/)[1],
                         doc.xpath('//div[@class="blog-update"]').text.scan(/\d+/)[2],
                         doc.xpath('//div[@class="blog-update"]').text.scan(/\d+/)[3],
                         doc.xpath('//div[@class="blog-update"]').text.scan(/\d+/)[4])
  @publish_year = doc.xpath('//div[@class="blog-update"]').text.scan(/\d+/)[0]
  @publish_month = doc.xpath('//div[@class="blog-update"]').text.scan(/\d+/)[1]
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

@debug = false
imgdir = ARGV[0]
bfile = ARGV[1]
dmode = ARGV[2]

if bfile == nil
  puts "bfile not exist."
  exit 1
end

if imgdir == nil
  puts "imgdir not exist."
  exit 1
end

images = parseBFile(bfile)
puts "====== image file relocation start ====="
puts "Img Dir: #{imgdir}"
puts "Article File: #{bfile}"
puts "Publish Date: #{@pubDate}"
puts "Year: #{@publish_year} / Month: #{@publish_month}"
puts ""

unless Dir.exist?("#{imgdir}/#{@publish_year}/#{@publish_month}")
   if dmode == "d"
     puts "MKDIR: #{imgdir}/#{@publish_year}/#{@publish_month}"
   else 
     FileUtils.mkdir_p("#{imgdir}/#{@publish_year}/#{@publish_month}")
     FileUtils.touch("#{imgdir}/#{@publish_year}/#{@publish_month}", :mtime => @pubDate)
   end
end

images.each do |i|
  if dmode == "d"
    puts "relocate: #{imgdir}/#{File.basename(i)}"
    puts "          ->  #{imgdir}/#{@publish_year}/#{@publish_month}/#{File.basename(i)}"
  else
    FileUtils.mv( "#{imgdir}/#{File.basename(i)}", 
                  "#{imgdir}/#{@publish_year}/#{@publish_month}/#{File.basename(i)}" )
    FileUtils.touch("#{imgdir}/#{@publish_year}/#{@publish_month}/#{File.basename(i)}", 
                    :mtime => @pubDate)
  end
end
