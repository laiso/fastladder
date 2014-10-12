source 'https://rubygems.org'
gem 'rails', '4.1.6'

# Include database gems for the adapters found in the database
# configuration file or DATABASE_URL
require 'erb'
require 'uri'
require 'yaml'

database_file = File.join(File.dirname(__FILE__), "config/database.yml")
adapters = []

if File.exist?(database_file)
  database_config = YAML::load(ERB.new(IO.read(database_file)).result)
  adapters += database_config.values.map {|conf| conf['adapter']}.compact.uniq
end

if database_url = ENV['DATABASE_URL']
  adapters << URI.parse(database_url).scheme
end

if adapters.any?
  adapters.each do |adapter|
    case adapter
    when 'mysql2'     ; gem 'mysql2'
    when 'mysql'      ; gem 'mysql'
    when /postgres/   ; gem 'pg'
    when /sqlite3/    ; gem 'sqlite3'
    else
      warn("Unknown database adapter `#{adapter}` found in config/database.yml, use Gemfile.local to load your own database gems")
    end
  end
else
  warn("No adapter found in config/database.yml or DATABASE_URL, please configure it first -- fallback to pg")
  gem 'pg'
end

gem 'addressable', require: 'addressable/uri'
gem 'coffee-rails', '~> 4.0.0'
gem 'feed_searcher', '>= 0.0.6'
gem 'feedjira'
gem 'haml'
gem 'i18n-js', github: 'fnando/i18n-js'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'mini_magick'
gem 'nokogiri'
gem 'opml', github: 'fastladder/opml'
gem 'sass-rails', '~> 4.0.0'
gem 'settingslogic'
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'
gem 'feedly2fastladder'

group :development do
  gem 'annotate'
  gem 'pry'
  gem 'pry-doc'
  gem 'pry-rails'
  gem 'quiet_assets'
end

group :test do
  gem 'capybara'
  gem 'coveralls', require: false
  gem 'eventmachine', github: 'eventmachine/eventmachine', ref: '4d53154a9e' # v1.0.3 cannot compile on ruby 2.2.0
  gem 'factory_girl_rails', group: :development
  gem 'konacha', group: :development
  gem 'launchy'
  gem 'poltergeist'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-rails', group: :development
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'sinon-rails'
  gem 'thin'
  gem 'webmock'
end

group :production do
  gem 'rails_12factor'
  gem 'unicorn'
end

group :doc do
  gem 'sdoc', require: false
end
