source "https://rubygems.org"

def darwin_only(require_as)
  RUBY_PLATFORM.include?('darwin') && require_as
end

def linux_only(require_as)
  RUBY_PLATFORM.include?('linux') && require_as
end

gem "rails", "~> 4.0.0"

gem "protected_attributes"
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'

# Default values for AR models
gem "default_value_for", "~> 3.0.0"

# Supported DBs
gem 'sqlite3'
gem 'mysql2', group: :mysql

# Auth
gem "devise", '3.0.4'
gem 'omniauth', "~> 1.1.3"
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'
gem 'omniauth-github'

# Ruby/Rack Git Smart-HTTP Server Handler
gem 'gitlab-grack', '~> 2.0.0.pre', require: 'grack'

# LDAP Auth
gem 'gitlab_omniauth-ldap', '1.0.4', require: "omniauth-ldap"

# Git Wiki
gem "gitlab-gollum-lib", "~> 1.1.0", require: 'gollum-lib'

# API
gem "grape", "~> 0.6.1"
gem "grape-entity", "~> 0.3.0"
gem 'rack-cors', require: 'rack/cors'

# Email validation
gem "email_validator", "~> 1.4.0", :require => 'email_validator/strict'

# Format dates and times
# based on human-friendly examples
gem "stamp"

# Enumeration fields
gem 'enumerize'

# Pagination
gem "kaminari", "~> 0.15.1"

# HAML
gem "haml-rails"

# Files attachments
gem "carrierwave"

# for aws storage
gem "fog", "~> 1.3.1", group: :aws

# Authorization
gem "six"

# Seed data
gem "seed-fu"

# Markdown to HTML
gem "redcarpet",     "~> 2.2.2"
gem "github-markup", "~> 0.7.4", require: 'github/markup', git: 'https://github.com/gitlabhq/markup.git', ref: '61ade389c1e1c159359338f570d18464a44ddbc4' 

# Asciidoc to HTML
gem  "asciidoctor"

# Application server
group :unicorn do
  gem "unicorn", '~> 4.6.3'
  gem 'unicorn-worker-killer'
end

# State machine
gem "state_machine"

# Issue tags
gem "acts-as-taggable-on"

# Background jobs
gem 'slim'
gem 'sinatra', require: nil

# HTTP requests
gem "httparty"

# Colored output to console
gem "colored"

# GitLab settings
gem 'settingslogic'

# Flowdock integration
gem "gitlab-flowdock-git-hook", "~> 0.4.2"

# d3
gem "d3_rails", "~> 3.1.4"

# underscore-rails
gem "underscore-rails", "~> 1.4.4"

# Sanitize user input
gem "sanitize"

# Protect against bruteforcing
gem "rack-attack"

# Ace editor
gem 'ace-rails-ap', github: "bL0p/ace-rails-ap", branch: "new_vendor_modes"

# https://github.com/twbs/bootstrap-sass/issues/560
gem 'sprockets', '=2.11.0'

gem "sass-rails"
gem "coffee-rails"
gem "uglifier"
gem "therubyracer"
gem 'turbolinks'
gem 'jquery-turbolinks'

gem 'select2-rails'
gem 'jquery-atwho-rails', "~> 0.3.3"
gem "jquery-rails",     "3.1.2"
# gem "jquery-rails",     "2.1.3"
gem "jquery-ui-rails",  "2.0.2"
gem "modernizr-rails", "2.7.1"
gem "raphael-rails", "~> 2.1.2"
gem 'bootstrap-sass', '~> 3.0'
gem "font-awesome-rails", '~> 3.2'
gem "gemoji", "~> 1.3.0"


group :development do
  gem "annotate", "~> 2.6.0.beta2"
  gem "letter_opener"
  gem 'quiet_assets', '~> 1.0.1'
  gem 'rack-mini-profiler', require: false

  # Better errors handler
  gem 'better_errors', "1.1.0"
  gem 'binding_of_caller'

  gem 'rails_best_practices'

  # Docs generator
  gem "sdoc"

  # thin instead webrick
  gem 'thin'

  gem 'meta_request'
end

group :development, :test do
  gem 'coveralls', require: false
  # gem 'rails-dev-tweaks'
  gem 'spinach-rails'
  gem "rspec-rails"
  gem "pry"
  gem "pry-rails"
  gem "pry-stack_explorer"
  gem "pry-debugger"
  gem "capybara", '2.2.0'
  gem "awesome_print"
  gem "database_cleaner"
  gem "launchy"
  gem 'factory_girl_rails'

  # Prevent occasions where minitest is not bundled in packaged versions of ruby (see #3826)
  gem 'minitest', '~> 4.7.0'

  # Generate Fake data
  gem "ffaker"

  # Guard
  gem 'guard-rspec'
  gem 'guard-spinach'

  # Notification
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'growl',      require: darwin_only('growl')
  gem 'rb-inotify', require: linux_only('rb-inotify')

  # PhantomJS driver for Capybara
  gem 'poltergeist', '~> 1.5.1'

  gem 'spork', '~> 1.0rc'
  gem 'jasmine', '2.0.0.rc5'

  gem "spring", '1.1.1'
  gem "spring-commands-rspec", '1.0.1'
  gem "spring-commands-spinach", '1.0.0'
end

group :test do
  gem "simplecov", require: false
  gem "shoulda-matchers", "~> 2.1.0"
  gem 'email_spec'
  gem "webmock"
  gem 'test_after_commit'
end

group :production do
  gem "gitlab_meta", '6.0'
end

gem 'jenkins_api_client'
gem 'github-linguist', :git => 'git://github.com/pedro-ribeiro/linguist.git', :branch => 'production'

## gitlab-git dependencies
gem 'grit_ext'
gem 'rugged', '0.21.0'
gem 'charlock_holmes'

gem 'figaro'
gem 'sidekiq', '~> 3.0.0'

gem 'sshkey'