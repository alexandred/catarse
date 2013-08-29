if ENV['RAILS_ENV'] == 'development'
  namespace :assets do
    task(:precompile).overwrite do
      puts "Asset precompile skipped in #{ENV['RAILS_ENV']}"
    end
  end
end
