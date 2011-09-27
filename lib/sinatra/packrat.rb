# Gems includes
require "sinatra/base"
require "yaml"

module Sinatra
  module Packrat

    module Helpers
      # this allows for multiple view directories
      def find_template(views, name, engine, &block)
        Array(views).each { |v| super(v, name, engine, &block) }
      end

      private
      # Overwrite Sinatra::Base private method!!! (is this robust?)
      #
      # Allow settings.public to be an Array (or Enumerable...)
      # for multiple-path static file lookup.
      def static!
        return if settings.public.nil?
        if settings.public.respond_to? :each
          settings.public.each do |dir|
            public_dir = File.expand_path(dir)
            path = File.expand_path(public_dir + unescape(request.path_info))
            next unless path.start_with?(public_dir) and File.file?(path)
  
            env['sinatra.static_file'] = path
            send_file path, :disposition => nil
  
            break
          end
        else
          super
        end
      end
    end

    def self.registered(app)
      app.helpers Packrat::Helpers
      app.enable :static  # this is required for multiple public directories
      app.set :packrat, {}

      klass = app

      Kernel.class_exec do
        define_method :packrat do |&block|
          klass.class_exec &block
        end
      end
    end

    # Module initialization
  
    # Module views
    # in order for sinatra to be able to find the views of our modules,
    # we've modified the "find templates" helper above to allow for multiple
    # view directories.  this allows us to add each module's view directory to an array
    # and the set sinatra's "views" directory with that array.
  
    # Module public (static) assets
    # in order for sinatra to be able to find the static assets of our modules,
    # we've extended sinatra (in "lib/sinatra_extend") to allow for multiple
    # public directories.  this allows us to add each module's public directory to an array
    # and the set sinatra's "public" directory with that array.

    def add_view_path(path)
      cur_view = settings.views || []
      
      if cur_view.class == String
        cur_view = Array(cur_view)
      end
      
      cur_view << path
      set :views, cur_view
    end

    def add_public_path(path)
      cur_view = settings.public || []
      
      if cur_view.class == String
        cur_view = Array(cur_view)
      end
      
      cur_view << path
      set :public, cur_view
    end

    def register_modules_from_yaml(path)
      config = YAML.load_file( path )
      caller_path = File.dirname caller[0]

      config["modules"].each do |mod|

        if mod["path"]
          path = mod["path"]
        elsif mod["git"]
          git_repo = File.basename mod["git"], '.git'
          path = File.join 'modules/', git_repo
        end
        
        path = File.join(caller_path, path)
        pp path
        override_settings = mod["settings"]

        if override_settings
          register_module( full_module_path, override_settings )
        else 
          register_module full_module_path
        end

      end
    end
    
    def register_module(base_path, override_config = {})

      # if config file, load / add it to namespaced config hash
      config_path = File.join( base_path, "/config.yml" )

      if File.exists? config_path
        module_config = YAML.load_file(config_path)
      end

      if module_config
        module_id = module_config["module_id"]

        # put the settings in a namespaces 'm_#{module_id}' location as
        # well as a consolidated place (in case we want to inspect all)
        unless module_id.nil?
          module_config.delete "module_id"
          module_config.merge! override_config
          settings.packrat[module_id.to_sym] = module_config 
          set "m_#{module_id}".to_sym,module_config
        end
      end

      route_path = File.join base_path, "routes.rb"
      require route_path if File.exists? route_path
  
      view_path = File.join base_path, 'views'
      add_view_path(view_path) if File.directory?(view_path)
  
      public_path = File.join base_path, 'public'
      add_public_path(public_path) if File.directory?(public_path)
    end
  
  end
  
  register Packrat
end