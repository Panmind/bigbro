module PM
  module Piwik
    if Rails.env.production?
      Config = APPLICATION_CONFIG[:piwik]

      # *Enforce* analytics configuration in production mode
      #
      # If you're developing and want to run your local copy
      # in production mode, you can either add dumb settings
      # in your settings.yml, to check how the Piwik JS code 
      # is being generated:
      #
      #   :piwik:
      #     :url: http://localhost/piwik
      #     :id:  31337
      #
      # Or, if you're really not interested at all in any of
      # the Piwik bells and whistles, you can boldly disable
      # it via the following configuration:
      #
      #   :piwik:
      #     :i_really_want_to_disable_analytics: true
      #
      raise ArgumentError, 'Analytics configuration missing' if Config.blank?
    elsif Rails.env.test?
      Config = {:url => 'http://test.host/piwik', :id => 420}
    end

    def piwik_url
      #request.protocol + APPLICATION_CONFIG[:piwik][:path]
      Config[:url]
    end

    def piwik_id
      Config[:id]
    end

    def piwik_js
      piwik_url + '/piwik.js'
    end

    def piwik_php
      piwik_url + '/piwik.php'
    end

    def piwik_disabled?
      Rails.env.development? || Config[:i_really_want_to_disable_analytics]
    end

    def piwik_analytics(options = {})
      return if piwik_disabled?
      track = options.has_key?(:track) ? options[:track] : true
      embed = options.has_key?(:embed) ? options[:embed] : true

      html = ''
      html.concat(javascript_include_tag(piwik_js)) if embed
      html.concat(javascript_tag(%(
        try {
          var piwikTracker = Piwik.getTracker ('#{piwik_php}', #{piwik_id});
          #{track ? 'piwikTracker.trackPageView ();' : ''}
        } catch (err) {
          $.log ('Error while initializing analytics: ' + err);
        }
      )))

      html.concat(content_tag(:noscript,
        image_tag("#{piwik_php}?idsite=#{piwik_id}",
                  :style => 'border:0', :alt => '').html_safe
      ))

      return html.html_safe
    end

    module TestHelpers
      Tracker = /Piwik\.getTracker \('http:\/\/test\.host\/piwik\/piwik\.php', 420\)/

      def assert_piwik_analytics(options = {})
        embed = options.has_key?(:embed) ? options[:embed] : true

        if embed
          # Assert that the JS inclusion tag is defined, and it is positioned
          # before the inline js tag containing the .getTracker on the correct
          # host name and ID.
          #
          assert_tag :tag => 'script',
            :attributes => {
            :src  => 'http://test.host/piwik/piwik.js',
            :type => 'text/javascript'
          },
            :before => {
            :tag     => 'script',
            :content => Tracker
          }
        else
          assert_tag :tag => 'script', :content => Tracker
        end

        # Assert that the noscript tag with the descendant img tag is defined
        # on the correct host name and ID.
        #
        assert_tag :tag => 'noscript',
          :descendant => {
            :tag => 'img',
            :attributes => {
              :src => 'http://test.host/piwik/piwik.php?idsite=420',
              :style => 'border:0',
              :alt => ''
            }
          }
      end
    end

  end
end

