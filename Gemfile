source 'https://rubygems.org'

gem 'sequel',  '~> 4.30'
gem 'sqlite3', '~> 1.3', '>= 1.3.11'
gem 'docker-api', '~> 1.25'

group :tester do
  # core
  gem 'rubyzip',  '~> 1.1', '>= 1.1.7'
  gem 'minitest', '~> 5.8', '>= 5.8.3'

  # engines
  gem 'pg',        '~> 0.18.4'
  gem 'mysql2',    '~> 0.4.2'
  gem 'mongoid',   '~> 5.0', '>= 5.0.2'
  gem 'rethinkdb', '~> 2.2', '>= 2.2.0.2'

  # transports
  gem 'aws-sdk', '~> 2.2', '>= 2.2.12'
end

group :ui do
  gem 'sinatra', '~> 1.4', '>= 1.4.6'
  gem 'thin', '~> 1.6', '>= 1.6.4'
end

group :development do
  gem 'git-up'
end
