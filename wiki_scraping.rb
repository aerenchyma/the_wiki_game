require 'open-uri'
require 'nokogiri'
require 'mechanize'

# function to get array of depth-1 links
def get_links(page_url)
  ndoc = Nokogiri::HTML(open(page_url))
  links = ndoc.css('a')
  tmp = []
  # hrefs = links.map {|ln| ln.attribute('href').to_s}
  links.each do |ln|
    if ln.text == "next 5,000"
      # puts ln.text
      #     puts ln["href"]
      tmp = get_links("http://en.wikipedia.org" + ln["href"])
      tmp << ln["href"]
      break
    end
  end
  tmp
end

# CODE to get start and goal links

agent = Mechanize.new { |ag|
  ag.user_agent_alias = 'Mac Safari'
}

# 1: get the starting page
poss = agent.get('http://en.wikipedia.org/wiki/Portal:Contents/Portals')

# pick a random page on which to start
f = poss.links.sample
nr = f.uri.to_s

if nr =~ / /
  nr.gsub!(' ','%20') # TODO url encode, without the check
end
if nr =~ /^\w/
  nr.insert(0, '/')
end
if (nr =~ /file/ || nr =~ /File/ )
  f = poss.links.sample
  nr = f.uri.to_s
end
if nr =~ /^en\.wikipedia/ || nr =~ /.svg$/
  f = poss.links.sample
  nr = f.uri.to_s
end
st_url = "http://en.wikipedia.org#{nr}"


# 2: get the goal page
sec_agent = Mechanize.new { |ag| 
  ag.user_agent_alias = 'Mac Safari'
}

pot = sec_agent.get('http://en.wikipedia.org/wiki/Main_Page')
tl = pot.links.sample
pt = tl.uri.to_s

finstr = tl.to_s.gsub(' ', '%20')
if finstr =~ /[Hh]elp/ || finstr =~ /[Ff]ile/ || finstr =~ /Meta/
  tl = pot.links.sample
  finstr = tl.to_s.gsub(' ', '%20')
end
url = "https://en.wikipedia.org/#{finstr}"

start_name = f.to_s.gsub(' ', '%20')
goal_name = tl.to_s.gsub(' ', '%20')

###### END CODE to get start and goal links

#baselinks_url = "http://en.wikipedia.org/wiki/Special:WhatLinksHere/"
baselinks_url = "http://en.wikipedia.org/w/index.php?title=Special:WhatLinksHere/"


new_agent = Mechanize.new { |ag|
  ag.user_agent_alias = 'Mac Safari'
}

# defining struct for nodes -- string, integer (array index)
WikiNode = Struct.new(:link, :parent)

# array of Nodes
wiki_arr = []

# initializing array (real or testing):

#wiki_arr << WikiNode.new(goal_name,-1)
wiki_arr << WikiNode.new("2007", -1)

#wikidoc = Nokogiri::HTML(open(baselinks_url + wiki_arr[0].link))

#p text(wikidoc.xpath(".//ul[@id='mw-whatlinkshere-list']/li[1]/a"))

curr_url = baselinks_url + wiki_arr[0].link + "\&limit=5000"
# pg = new_agent.get(curr_url)

arr = get_links(curr_url)

parent = 0
#xpathstr = ".//ul[@id='mw-whatlinkshere-list']/li[#{num}]/a"
pg = new_agent.get(arr[0])
(1..5000).each do |ck|
  t = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[#{ck}]/a/text()").to_s.gsub(' ', '%20')
  if t == ""
    break
  else
    wiki_arr << WikiNode.new(t,parent)
  end
end

arr.shift

arr.each do |elem|
 # wikidoc = Nokogiri::HTML(open(elem))
  pg = new_agent.get(elem)
  (1..5000).each do |num|
    t = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[#{num}]/a/text()").to_s.gsub(' ', '%20')
    wiki_arr << WikiNode.new(t,parent)
  end
end

wiki_arr.each do |l|
  puts l.link
end


# check for next 5000 link

#puts baselinks_url + wiki_arr[0].link + 
puts curr_url
doc = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[5001]/a/text()").to_s.gsub(' ', '%20')
doc2 = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[4999]/a/text()").to_s.gsub(' ', '%20')
doc3 = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[5000]/a/text()").to_s.gsub(' ', '%20')
# fulldoc = Nokogiri::HTML(open(curr_url))
#p doc
# p doc
# p doc2
# p doc3



# arr = get_links(curr_url)
# p arr

