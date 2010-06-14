module PM
  module Analytics
    if Rails.env.production?
      Config = APPLICATION_CONFIG[:analytics]

      # *Enforce* analytics configuration in production mode
      #
      # If you're developing and want to run your local copy
      # in production mode, you can either add dumb settings
      # in your settings.yml, to check how the GAnal JS code
      # is being generated:
      #
      #   :analytics:
      #     :id:  "UA-31337-00"
      #
      # Or, if you're really not interested at all in any of
      # the Analytics bells and whistles, you can boldly disable
      # it via the following configuration:
      #
      #   :analytics:
      #     :i_really_want_to_disable_analytics: true
      #
      raise ArgumentError, 'Analytics configuration missing' if Config.blank?
    elsif Rails.env.test?
      Config = {:id => 'UA-420-THEBRAIN'}
    end

    module Helpers
      def analytics(options = {})
        return if Analytics.disabled?

        track = options.has_key?(:track) ? options[:track] : true

        ga_host = Analytics.host_for(request)
        ga_cmds = [['setAccount', Analytics.account]]
        ga_cmds.push(['trackPageView']) if track

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
          image_tag(Analytics.noscript_image_path_for(request, ga_host),
                    :border => '0', :alt => '').html_safe
        ))

        return code.html_safe
      end
    end

    class << self
      def account
        Config[:id]
      end

      def disabled?
        Rails.env.development? || Config[:i_really_want_to_disable_analytics]
      end

      def host_for(request)
        (request.ssl? ? 'https://ssl' : 'http://www') + '.google-analytics.com'
      end

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
      def assert_analytics
        host = Analytics.host_for(@request)

        # Assert the GA <script> tag, with not much effort
        #
        assert_tag :tag => 'script', :content => /#{host}\/ga.js/

        # Assert the noscript tag with the descendant img
        #
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
