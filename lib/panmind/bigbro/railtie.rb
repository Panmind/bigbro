require 'panmind/bigbro'

module Panmind
  module BigBro

    if defined? Rails::Railtie
      require 'rails'
      class Railtie < Rails::Railtie
        initializer 'panmind-bigbro.insert_into_action_view' do
          ActiveSupport.on_load :action_view do
            Panmind::BigBro::Railtie.insert
          end
        end
      end
    end

    class Railtie
      def self.insert
        ActionView::Base.instance_eval { include Panmind::BigBro::Helpers }
        ActiveSupport::TestCase.instance_eval { include Panmind::BigBro::TestHelpers } if Rails.env.test?
      end
    end

  end
end
