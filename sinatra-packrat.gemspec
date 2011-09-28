Gem::Specification.new do |s|
  s.name        = 'sinatra-packrat'
  s.version     = '0.1.0'
  s.date        = '2011-09-21'
  s.summary     = "Sinatra extension to enable modular application design"
  s.description = "Packrat is a Sinantra extension based around the idea of mixing and matching. With Packrat we can combine multiple Sinatra applications into one instance, where they can share configuration data, filters, css and other static assets. Creating a new site out of existing pieces should be as simple as cloning a series of pieces, and for each one, adding one line to a config file."
  s.authors     = ["Brennan Roberts", "Brandon Harvey"]
  s.email       = 'brennan@oblong.com'
  s.files       = ["lib/sinatra/packrat.rb"]
  s.executables << 'packrat'
  s.homepage    = 'http://rubygems.org/gems/sinatra-packrat'
end