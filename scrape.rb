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

# check nokogiri object of url to see if "Wikipedia does not have an article with this exact name" is anywhere on the page, if so, get another, if not, OK cool

puts "Your goal page is #{tl}. \n URL: #{url}"
#puts "Wait a moment at the page for redirection if it seems odd. <msg about contacting re: errors>"



# occasional problems remain, e.g. https://en.wikipedia.org/wiki/%D0%A1%D1%80%D0%BF%D1%81%D0%BA%D0%B8_/_srpski
# (it's not an english page so there is nothing to show, no reasonable redirection)
# check text on page?

 #####

# quit crawling/searching if the time diff is greater than 120, 'cos it measures in seconds (POSIX?)
# see if that's reasonable time for Ruby

# 3: crawl until successful FTW
start_url = st_url
goal_url =  url
goal_title = tl.to_s






# nag = Mechanize.new { |ag|
#   ag.user_agent_alias = 'Mac Safari'
# }

#nxt_pg = ''
# bgn_pg = nag.get(start_url)

# want all that have 
## ___<a href="/wiki/___ + \w*
# poss_links = bgn_pg.links.find_all { |ls| ls.attributes.parent.name == 'a href'  }
# puts "here are poss links, #{poss_links}"


# until nxt_pg == goal_title do
#   
# end