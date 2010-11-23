require 'rake'
require 'rake/rdoctask'

require 'lib/panmind/bigbro'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name             = 'panmind-bigbro'

    gemspec.summary          = 'A Google Analytics plugin for Rails'
    gemspec.description      = 'BigBro provides view helpers to generate Analytics code '      \
                               '(with the noscript counterpart), test helpers to assert your ' \
                               'page contains the tracking code and a configuration method to '\
                               'set your GA account from environment.rb'

    gemspec.authors          = ['Marcello Barnaba']
    gemspec.email            = 'vjt@openssl.it'
    gemspec.homepage         = 'http://github.com/Panmind/bigbro'

    gemspec.files            = %w( README.md Rakefile rails/init.rb ) + Dir['lib/**/*']
    gemspec.extra_rdoc_files = %w( README.md )
    gemspec.has_rdoc         = true

    gemspec.version          = Panmind::BigBro::Version
    gemspec.date             = '2010-11-23'

    gemspec.require_path     = 'lib'

    gemspec.add_dependency('rails', '~> 3.0')
  end
rescue LoadError
  puts 'Jeweler not available. Install it with: gem install jeweler'
end

desc 'Generate the rdoc'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.add %w( README.md lib/**/*.rb )

  rdoc.main  = 'README.md'
  rdoc.title = 'BigBro: A Google Analytics plugin for Rails'
end

desc 'Will someone help write tests?'
task :default do
  puts
  puts 'Can you help in writing tests? Please do :-)'
  puts
end
