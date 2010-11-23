require 'panmind/bigbro/railtie' if defined? Rails

module Panmind
  module BigBro
    Version = '0.9'

    module Helpers
      # Embeds the optimized Analytics code and the noscript tag with
      # the direct path to the __utm.gif image into the current page.
      #
      # If the `:track` option is set to false, the current page load
      # is *not* automatically tracked: you should track it later via
      # the JS API.
      #
      def analytics(options = {})
        return if BigBro.disabled?

        track = options.has_key?(:track) ? options[:track] : true

        ga_host = BigBro.host_for(request)
        ga_cmds = [['_setAccount', BigBro.account]]
        ga_cmds.push ['_setDomainName', BigBro.domain] if BigBro.domain
        ga_cmds.concat(options[:commands]) if options[:commands]
        ga_cmds.push ['_trackPageview']    if track

        code = ''
        code.concat javascript_tag(%(
          var _gaq = #{ga_cmds.to_json};
          $(document).ready (function () { // Because of Opera and FF <= 3.5
            try {
              (function(d, t, a) {
                var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
                g[a]=a;g.src='#{ga_host}/ga.js';s.parentNode.insertBefore(g,s);
              }) (document, 'script', 'async');
            } catch (err) {}
          });
        ))

        code.concat(content_tag(:noscript,
          image_tag(BigBro.noscript_image_path_for(request, ga_host),
                    :border => '0', :alt => '').html_safe
        ))

        return code.html_safe
      end
    end

    class << self
      attr_accessor :account, :domain, :disabled

      # Sets the Analytics account and *enforces* it to be set
      # in production mode.
      #
      # If you're developing and want to run your local copy
      # in production mode, you can either pass an invalid
      # account (e.g. to check how the JS code is generated)
      # or pass the :disabled option set to true.
      #
      # In test mode, the account is always set to the dummy
      # "UA-420-THEBRAIN" string.
      #
      # Sets the 'UA-12345-67' account:
      #
      #   Panmind::BigBro.set(:account => 'UA-12345-67')
      #
      # Sets the 'UA-12345-67' account and the 'foo.com' domain:
      #
      #   Panmind::BigBro.set(:account => 'UA-12345-67', :domain => 'foo.com')
      #
      # Disables analytics code generation:
      #
      #   Panmind::BigBro.set(:disabled => true)
      #
      def set(options = {})
        self.account, self.disabled, self.domain =
          options.values_at(:account, :disabled, :domain)

        if Rails.env.production?
          if self.account.blank? && !self.disabled
            raise ArgumentError, 'BigBro: analytics configuration missing'
          end
        elsif Rails.env.test?
          self.account = 'UA-420-THEBRAIN'
        end
      end

      # In development mode the Analytics code is always disabled,
      # or it can be disabled manually via the configuration.
      #
      # If no account is set, the code disables itself. Maybe the
      # check in the set() method should be moved here, we'll see.
      #
      def disabled?
        self.disabled || self.account.blank? || Rails.env.development?
      end

      # Returns the analytics host for the given request (SSL or not)
      #
      def host_for(request)
        (request.ssl? ? 'https://ssl' : 'http://www') + '.google-analytics.com'
      end

      # Returns the noscript image path for the given request and GA Host
      #
      def noscript_image_path_for(request, ga_host)
        cookie = rand(   89_999_999) +    10_000_000
        req_no = rand(8_999_999_999) + 1_000_000_000
        random = rand(1_147_483_647) + 1_000_000_000
        now    = Time.now.to_i

        referer = request.referer.blank? ? '-' : CGI.escape(request.referer)
        path    = request.path.blank?    ? '/' : CGI.escape(request.path)

        utmcc =
          "__utma%3D#{cookie}.#{random}.#{now}.#{now}.#{now}.2%3B%2B" \
          "__utmz%3D#{cookie}.#{now}.2.2."                            \
            "utmccn%3D(direct)%7C"       \
            "utmcsr%3D(direct)%7C"       \
            "utmcmd%3D(none)%3B%2B"      \
         "__utmv%3D#{cookie}.noscript%3B"

        "#{ga_host}/__utm.gif?"    \
          "utmn=#{req_no}&"        \
          "utmac=#{account}&"      \
          "utmhn=#{request.host}&" \
          "utmr=#{referer}&"       \
          "utmp=#{path}&"          \
          "utmcc=#{utmcc}&"        \
          'utmwv=1&'               \
          'utmje=0&'               \
          'utmsr=-&'               \
          'utmsc=-&'               \
          'utmul=-&'               \
          'utmfl=-&'               \
          'utmdt=-'
      end
    end

    module TestHelpers
      # Asserts the GA <script> tag, with not much effort;
      # Asserts the noscript tag with the descendant img.
      #
      def assert_analytics
        host = BigBro.host_for(@request)

        assert_tag :tag => 'script', :content => /#{host}\/ga.js/

        assert_tag :tag => 'noscript',
          :descendant => {
            :tag => 'img',
            :attributes => {
              :src => /#{host}\/__utm.gif\?/,
              :border => '0',
              :alt => ''
            }
          }
      end
    end
  end
end
