require 'digest/md5'
require 'nokogiri'
require 'open-uri'
require 'curb'

start = ARGV[0]
num   = ARGV[1]

doc = Nokogiri::XML.parse(open("http://tumblr.igvita.com/api/read/?start=#{start}&num=#{num}&type=quote").read)
doc.search('post').each do |post|
  text   = post.search('quote-text').text.gsub(/&#\d+;/,'')
  source = post.search('quote-source').text.gsub(/<\/?[^>]*>/,'')

  c = Curl::Easy.http_post("http://imagequote.heroku.com/quote",
                           Curl::PostField.content('quote', text),
                           Curl::PostField.content('source', source))

  c.perform

  File.open('out/' + Digest::MD5.hexdigest(text) + ".png", "w") {|f| f.puts c.body_str }
end
