require 'open-uri'
require 'nokogiri'
require 'mechanize'

# function to get array of depth-1 links
def get_links(page_url)
  ndoc = Nokogiri::HTML(open(page_url))
  links = ndoc.css('a')
  tmp = []
  found = nil
  links.each do |ln|
    if ln.text == "next 5,000"
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

def print_path(win_node)
    curr_node = win_node
    while curr_node.parent != nil
      puts curr_node.text
      #curr_node = $wiki_arr[curr_node.parent]
      curr_node = $wiki_hash[curr_node.parent]
    end
    puts curr_node.text
end

# def in_previous(text)
#   $wiki_arr.each do |c|
#     if c.text == text
#       return true
#     end
#   end
#   return false
# end

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
#start_name = "1792" # engineered win
#goal_name = tl.to_s.gsub(' ', '%20') 
#goal_name = "Jane%20Austen" # engineered win
start_name = "Hacker%20(term)" # engineering again
goal_name = "Ruby%20on%20Rails" # engineering again

###### END CODE to get start and goal links

#baselinks_url = "http://en.wikipedia.org/wiki/Special:WhatLinksHere/"
baselinks_url = "http://en.wikipedia.org/w/index.php?title=Special:WhatLinksHere/"


new_agent = Mechanize.new { |ag|
  ag.user_agent_alias = 'Mac Safari'
}

# defining struct for nodes -- string, integer (array index)
WikiNode = Struct.new(:link, :parent, :text)

# array of Nodes
$wiki_arr = []

# initializing hashes
$wiki_hash = {}

# initializing array (real or testing):
puts  " link: #{baselinks_url+goal_name}, text: #{goal_name}"
#$wiki_arr << WikiNode.new(baselinks_url + goal_name,-1, goal_name)
$wiki_hash[goal_name] = WikiNode.new(baselinks_url + goal_name, nil, goal_name)

#$wiki_arr << WikiNode.new("2007", -1)

parent = 0
win = nil
while $wiki_hash.keys.length > parent #&& parent < 5
  puts "parent is now: #{parent}"
  sleep 0.1 # delay .1 secs
  curr_url = $wiki_hash[$wiki_hash.keys[parent]].link + "\&limit=5000"
  #puts curr_url
  parent_text = $wiki_hash[$wiki_hash.keys[parent]].text
  arr = get_links(curr_url)
  #p arr
  pg = new_agent.get(arr[0]) 


  if not arr.empty?
    if win 
       break
    end
    arr.each do |elem|
     # wikidoc = Nokogiri::HTML(open(elem))
      pg = new_agent.get(elem)
      #(1..5000).each do |num|
      num = 1
      txt = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[#{num}]/a/text()").to_s.gsub(' ', '%20')
      t = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[#{num}]/span[@class='mw-whatlinkshere-tools']/a/@href").to_s.gsub(' ', '%20')
      while txt != ""
        if t =~ /target=User/ || t =~ /target=Talk/ || t =~ /target=Template/
          # do nothing
        else
          p txt # so you can see where it's going
          if !$wiki_hash.has_key?(txt)
            #$wiki_arr << WikiNode.new("http://en.wikipedia.org" + t, parent, txt)
            $wiki_hash[txt] = WikiNode.new("http://en.wikipedia.org" + t, parent_text, txt)
          end
        end
        if txt == start_name
          puts "Win\n"
          print_path($wiki_hash[$wiki_hash.keys.last])
          win = true
          break
        end

        num += 1
        txt = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[#{num}]/a/text()").to_s.gsub(' ', '%20')
        t = Nokogiri::HTML(pg.body).xpath(".//ul[@id='mw-whatlinkshere-list']/li[#{num}]/span[@class='mw-whatlinkshere-tools']/a/@href").to_s.gsub(' ', '%20')
      end
    end
  end
  if win 
     break
  end
  parent += 1
end

