source 'https://rubygems.org'

ruby File.read(File.expand_path('.ruby-version', __dir__)).strip

gem 'activerecord'
gem 'bcrypt', '~> 3.1.7'
gem 'colorize'
gem 'dotenv'
gem 'rack-flash3'
gem 'rake'
gem 'sinatra'
gem 'sinatra-activerecord'
gem 'sinatra-contrib'
gem 'warden'

group :development do
  gem 'rubocop'
  gem 'shotgun'
  gem 'sqlite3'
end

group :production do
  gem 'pg'
end
