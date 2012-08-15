require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'mechanize'

## code used in wiki_scrape.rb to gather random start and goal wiki links
## yes, there is a much easier way to do this: TODO

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
puts "Your start page is #{f}. \n URL: #{st_url}"

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

# check nokogiri object of url to see if "Wikipedia does not have an article with this exact name" is anywhere on the page, if so, get another, or deal w/ redirects

puts "Your goal page is #{tl}. \n URL: #{url}"

