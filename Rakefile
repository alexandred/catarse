# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

# found from http://blog.jayfields.com/2008/02/rake-task-overwriting.html
# used by conditional heroku asset compile magick
class Rake::Task
  def overwrite(&block)
    @actions.clear
    enhance(&block)
  end
end

Catarse::Application.load_tasks
