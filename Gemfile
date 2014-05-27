source 'https://rubygems.org'

# Specify your gem's dependencies in rsense.gemspec
gemspec

gem 'rsense-server', :github => 'rsense/rsense-server', :branch => 'master'

group :linux do
  gem 'libnotify'
end

group :darwin do
  gem 'terminal-notifier-guard'
end
