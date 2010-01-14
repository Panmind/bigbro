module PM
  module Piwik
    def piwik_base
      #request.protocol + 'backup1.panmind.org/piwik/'
      'https://backup1.panmind.org/piwik/'
    end

    def piwik_id
      1
    end

    def piwik_js
      piwik_base + 'piwik.js'
    end

    def piwik_php
      piwik_base + 'piwik.php'
    end

    Piwik = ''
    def piwik_analytics_tags
      if Piwik.blank?
        Piwik.replace(
          javascript_include_tag(piwik_js) +
          javascript_tag(%(
            try {
              var piwikTracker = Piwik.getTracker ('#{piwik_php}', #{piwik_id});

              piwikTracker.trackPageView ();
              piwikTracker.enableLinkTracking ();
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
  end
end

