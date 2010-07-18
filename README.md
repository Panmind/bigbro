BigBro: A Google Analytics plugin for Rails
===========================================

Installation
------------

    script/plugin install git://github.com/Panmind/bigbro.git

Gems will follow soon, hopefully after the July 22nd Ruby Social Club in Milan.

Usage
-----

After the plugin has been loaded, you'll have an `analytics` helper to use
in your views. It generates an optimized version of the Google Analytics
code, and a `<noscript>` tag containing the direct path to the `__utm.gif`
image, to track JS-disabled browsers as well.

The `analytics` helper tracks the current page load by default, you can
disable this behaviour by passing the `:track => false` option.

Configuration
-------------

You must set your analytics account via the `Panmind::BigBro.set()` method
in your `config/environment.rb`:

    Panmind::BigBro.set(:account => 'UA-12345-67')

In production mode, the `.set()` method will raise an `ArgumentError` if
no account is provided, unless the `:disabled` option is set to `true`.

We use these switches to allow the developer to run the application in
production mode on `localhost` while not sending requests to Analytics.

We know that the ga.js is empty if the `Referer` is `localhost`, but on
Panmind there are situations in which the referer is reset, thus a
complete disable is necessary

In development mode the plugin is always disabled.

Testing
-------

A simple `assert_analytics()` helper is included in to aid verifying
that the layouts include the `analytics` helper. Its usage is super
simple:

    class FooControllerTest < ActionController::TestCase
      context "An user" do
        should "be tracked by analytics" do
          get :index
          assert_analytics
        end
      end
    end

