Packrat is a Sinantra extension based around the idea of mixing and matching.
With Packrat we can combine multiple Sinatra applications into one instance,
where they can share configuration data, filters, css and other static assets.
Creating a new site out of existing pieces should be as simple as cloning a
series of pieces, and for each one, adding one line to a config file.

# Writing modules

A packrat module follows the same directory structure as a Sinatra application.
Templates within the `views` directory and files in the `public` directory will
become accessible to all other modules.

Define your module-specific routes within a `routes.rb`, wrapped inside of a
`packrat do ... end` block.

# Using modules

A base Sinatra app can be comprised of many packrat modules.

Specify your modules within a config.yml:

```yml modules:

# from a git repository
- git: https://github.com/example.git

# local directory
- path: ~/some/module/dir/

```

Run `packrat config.yml` to clone modules with a git sources into a local
`modules/` directory.

Then initialize the modules from your application:

```ruby
require "sinatra/base" require "sinatra/packrat"

class MyApp < Sinatra::Base
  register Sinatra::Packrat
  register_modules_from_yaml('config.yml')
end

```

# License

Sinatra Packrat is released under an MIT license.


