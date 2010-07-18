/**
 * Panmind Analytics JS API
 *
 * TODO: Documentation
 */
(function ($) {
  $.pmTrackAjaxView = function () {
    if (typeof (_gaq) == 'undefined') return;

    try {
      _gaq.push (['_trackPageview', $.location.getPathForTracking ()]);
    } catch (e) { }
  };

  $.pmTrackEvent = function (category, action) {
    if (typeof (_gaq) != 'undefined')

    try {
      _gaq.push (['_trackEvent', category, action]);
    } catch (e) { }
  };

  var trackClick = function (elem, fn) {
    if (typeof (_gaq) != 'undefined')
      $(elem).click (function () {
        try { fn.apply (this); } catch (e) { }
      });

    return elem;
  };

  $.fn.pmTrackPageView = function () {
    return trackClick (this, function () {
      _gaq.push (['_trackPageview', $(this).attr ('href')]);
    });
  };

  $.fn.pmTrackDownload = function () {
    return trackClick (this, function () {
      _gaq.push (['_trackEvent', 'download', $(this).attr ('href')]);
    });
  };

  $.fn.pmTrackOutboundLink = function () {
    return trackClick (this, function () {
      _gaq.push (['_trackEvent', 'outbound', $(this).attr ('href')]);
    });
  };
}) (jQuery);
