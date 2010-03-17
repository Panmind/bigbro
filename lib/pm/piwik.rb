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
    elsif Rails.env.test? || Rails.env == 'cucumber'
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

    Piwik = ''
    def piwik_analytics_tags
      return if piwik_disabled?

      if Piwik.blank?
        Piwik.replace(
          javascript_include_tag(piwik_js) +
          javascript_tag(%(
            try {
              var piwikTracker = Piwik.getTracker ('#{piwik_php}', #{piwik_id});

              piwikTracker.trackPageView ();
            } catch (err) {
              $.log ('Error while initializing analytics: ' + err);
            }
          )) +
          content_tag(:noscript, image_tag("#{piwik_php}?idsite=#{piwik_id}",
                                           :style => 'border:0', :alt => ''))
        )
      end

      return Piwik
    end

    module TestHelpers
      def assert_piwik_analytics
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
            :content => /Piwik\.getTracker \('http:\/\/test\.host\/piwik\/piwik\.php', 420\)/
          }

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

