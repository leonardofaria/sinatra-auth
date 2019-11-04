puts 'Creating default user...'

User.create!(username: ENV['DEFAULT_USER'], password: ENV['DEFAULT_PASS'])
