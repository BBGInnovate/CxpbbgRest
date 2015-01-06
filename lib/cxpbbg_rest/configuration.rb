require 'erb'

module CxpbbgRest #:nodoc:
    #
    # Cxp::Bbgis configured via the config/cxp_bbg.yml file, which
    # contains properties keyed by environment name. A sample sunspot.yml file
    # would look like:
    #
    #   development:
    #       scheme: http
    #       user: username
    #       pass: password
    #       hostname: localhost
    #       port: 3001
    #       path: /api/contents/feed
    #   production:
    #       scheme: https
    #       user: username
    #       pass: password
    #       hostname: localhost
    #       port: 443
    #       path: /api/contents/feed
    #       open_timeout: 300
    #       read_timeout: 300
    #


    class Configuration
      attr_writer :user_configuration
      
      def endpoint
        hostport = (port==80 || port==443) ? '' : ":#{port}"
        hostpath = path.match(/^\//)? path : "/"+path
        "#{scheme}://#{hostname}#{hostport}#{hostpath}"
        if api_key
          hostpath = "#{hostpath}/?api_key=#{api_key}"
        end
        
      end
      
      def api_key
        @api_key ||= user_configuration_from_key('api_key')
        if @api_key && @api_key.strip.empty?
          nil
        else
          @api_key
        end
      end
      
      #
      # The user name in basic_auth to connect to CXP. 
      #
      # ==== Returns
      #
      # String:: user name
      #
      def username
        unless defined?(@username)
          @username ||= user_configuration_from_key('username')
          @username ||= default_username
        end
        @username
      end
      #
      # The password in basic_auth to connect to CXP. 
      #
      # ==== Returns
      #
      # String:: password
      #
      def password
        unless defined?(@password)
          @password ||= user_configuration_from_key('password')
          @password ||= default_password
        end
        @password
      end
      
      def read_timeout
        unless defined?(@read_timeout)
          @read_timeout ||= user_configuration_from_key('read_timeout')
          @read_timeout ||= default_read_timeout
        end
        @read_timeout
      end
      
      def open_timeout
        unless defined?(@open_timeout)
          @open_timeout ||= user_configuration_from_key('open_timeout')
          @open_timeout ||= default_open_timeout
        end
        @open_timeout
      end
      
      #
      # The host name at which to connect to CXP. Default 'localhost'.
      #
      # ==== Returns
      #
      # String:: host name
      #
      def hostname
        unless defined?(@hostname)
          @hostname ||= user_configuration_from_key('hostname')
          @hostname ||= default_hostname
        end
        @hostname
      end

      #
      # The port at which to connect to Solr.
      # ==== Returns
      #
      # Integer:: port
      #
      def port
        unless defined?(@port)
          @port ||= user_configuration_from_key('port')
          @port ||= default_port
          @port   = @port.to_i
        end
        @port
      end

      #
      # The scheme to use, http or https.
      # Defaults to http
      #
      # ==== Returns
      #
      # String:: scheme
      #
      def scheme
        unless defined?(@scheme)
          @scheme ||= user_configuration_from_key('scheme')
          @scheme ||= default_scheme
        end
        @scheme = "https" if @port == 443
        @scheme
      end

      #
      # The url path to the Solr servlet (useful if you are running multicore).
      # Default '/solr/default'.
      #
      # ==== Returns
      #
      # String:: path
      #
      def path
        unless defined?(@path)
          @path ||= user_configuration_from_key('path')
          @path ||= default_path
        end
        @path
      end

      private

      #
      # return a specific key from the user configuration in config/cxpbbg.yml
      #
      # ==== Returns
      #
      # Mixed:: requested_key or nil
      #
      def user_configuration_from_key( *keys )
        keys.inject(user_configuration) do |hash, key|
          hash[key] if hash
        end
      end

      #
      # Memoized hash of configuration options for the current Rails environment
      # as specified in config/bbg_cxp.yml
      #
      # ==== Returns
      #
      # Hash:: configuration options for current environment
      #
      def user_configuration
        @user_configuration ||=
          begin
            path = File.join(::Rails.root, 'config', 'cxpbbg.yml')
            if File.exist?(path)
              File.open(path) do |file|
                processed = ERB.new(file.read).result
                YAML.load(processed)[::Rails.env]
              end
            else
              {}
            end
          end
      end

    protected

      def default_hostname
        'localhost'
      end

      def default_path
        '/api/contents/feed'
      end
      
      def default_username
        'name'
      end
      
      def default_password
        'secret'
      end
      
      def default_port
        { 'test'        => 80,
          'development' => 3001,
          'production'  => 80
        }[::Rails.env]  || 80
      end

      def default_scheme
        'http'
      end

      def default_read_timeout
        nil
      end
      
      def default_open_timeout
        nil
      end
      
    end
end
