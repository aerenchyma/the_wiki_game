require 'open-uri'
require 'nokogiri'
require 'mechanize'

# function to get array of depth-1 links
def get_links(page_url)
  ndoc = Nokogiri::HTML(open(page_url))
  links = ndoc.css('a')
  tmp = []
  found = nil
  # hrefs = links.map {|ln| ln.attribute('href').to_s}
  links.each do |ln|
    #found = nil
    if ln.text == "next 5,000"
      # puts ln.text
      #     puts ln["href"]
      tmp = get_links("http://en.wikipedia.org" + ln["href"])
      tmp << "http://en.wikipedia.org" + ln["href"]
      found = true
      break
    end
  end
  if found == nil
    tmp << page_url
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

#start_name = f.to_s.gsub(' ', '%20')
start_name = "England"
#goal_name = tl.to_s.gsub(' ', '%20')
goal_name = "Jane%20Austen"

#puts start_name

###### END CODE to get start and goal links

#baselinks_url = "http://en.wikipedia.org/wiki/Special:WhatLinksHere/"
baselinks_url = "http://en.wikipedia.org/w/index.php?title=Special:WhatLinksHere/"


new_agent = Mechanize.new { |ag|
  ag.user_agent_alias = 'Mac Safari'
}

# defining struct for nodes -- string, integer (array index)
WikiNode = Struct.new(:link, :parent, :text)

# array of Nodes
wiki_arr = []

# initializing array (real or testing):
puts  " link: #{baselinks_url+goal_name}, text: #{goal_name}"
wiki_arr << WikiNode.new(baselinks_url + goal_name,-1, goal_name)
#wiki_arr << WikiNode.new("2007", -1)

#wikidoc = Nokogiri::HTML(open(baselinks_url + wiki_arr[0].link))

#p text(wikidoc.xpath(".//ul[@id='mw-whatlinkshere-list']/li[1]/a"))


# full url to start with
# curr_url = baselinks_url + wiki_arr[parent].link + "\&limit=5000"
# 
# 
# # actual array of links
# arr = get_links(curr_url)


#xpathstr = ".//ul[@id='mw-whatlinkshere-list']/li[#{num}]/a" ## xpath str example

parent = 0
win = nil
while wiki_arr.length > parent && parent < 5
  puts "parent is now: #{parent}"

  curr_url = wiki_arr[parent].link + "\&limit=5000"
  puts curr_url
  arr = get_links(curr_url)
  p arr
  pg = new_agent.get(arr[0]) # error: arr[0] seems to begin /w/ ... missing the full url getting: where?
  # (1..10).each do |ck|
  #   txt = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[#{ck}]/a/text()").to_s.gsub(' ','%20')
  #   t = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[#{ck}]/span[@class='mw-whatlinkshere-tools']/a/@href").to_s.gsub(' ', '%20')
  #   if t == ""
  #     break
  #   else
  #     wiki_arr << WikiNode.new("http://en.wikipedia.org" + t, parent, txt)
  #     if txt == start_name
  #       puts "Win"
  #       win = true
  #       break
  #     end
  #     p t
  #     p txt
  #   end
  # end
  # 
  # 
  # arr.shift # pops first element off

  if not arr.empty?
    if win 
       break
    end
    arr.each do |elem|
     # wikidoc = Nokogiri::HTML(open(elem))
      pg = new_agent.get(elem)
      (1..10).each do |num|
        txt = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[#{num}]/a/text()").to_s.gsub(' ', '%20')
        t = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[#{num}]/span[@class='mw-whatlinkshere-tools']/a/@href").to_s.gsub(' ', '%20')
        wiki_arr << WikiNode.new("http://en.wikipedia.org" + t, parent, txt)
        if txt == start_name
          puts "Win"
          win = true
          break
        end
       p t
       p txt
      end
    end
  end
  if win 
     break
  end
  parent += 1
end


# check for next 5000 link

#puts baselinks_url + wiki_arr[0].link + 
#puts curr_url
# doc = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[5001]/a/text()").to_s.gsub(' ', '%20')
# doc2 = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[4999]/a/text()").to_s.gsub(' ', '%20')
# doc3 = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[5000]/a/text()").to_s.gsub(' ', '%20')
# fulldoc = Nokogiri::HTML(open(curr_url))
#p doc
# p doc
# p doc2
# p doc3



# arr = get_links(curr_url)
# p arr


