require 'bigbro'

ActionView::Base.instance_eval { include Panmind::BigBro::Helpers }
ActiveSupport::TestCase.instance_eval { include Panmind::BigBro::TestHelpers } if Rails.env.test?
