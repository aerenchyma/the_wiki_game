require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'mechanize'

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
  fr = poss.links.sample
  nr = fr.uri.to_s
end
if nr =~ /^en\.wikipedia/ || nr =~ /.svg$/
  fr = poss.links.sample
  nr = fr.uri.to_s
end

puts "Your start page is #{fr ? fr : f}. \n URL: http://en.wikipedia.org#{nr}"

# 2: get the goal page
sec_agent = Mechanize.new { |ag| 
  ag.user_agent_alias = 'Mac Safari'
}

pot = sec_agent.get('http://en.wikipedia.org/wiki/Main_Page')
tl = pot.links.sample
pt = tl.uri.to_s



finstr = tl.to_s.gsub(' ', '%20')
if finstr =~ /[Hh]elp/ || finstr =~ /[Ff]ile/
  ntl = pot.links.sample
  finstr = ntl.to_s.gsub(' ', '%20')
end
puts "Your goal page is #{tl}. \n URL: https://en.wikipedia.org/#{finstr}"
#puts "Wait a moment at the page for redirection if it seems odd. <msg about contacting re: errors>"


