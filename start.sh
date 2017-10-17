# Install gems
bundle check || bundle install
# Run server
bundle exec puma -C config/puma.rb