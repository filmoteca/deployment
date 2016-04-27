set :application, "filmoteca"
set :repo_url,  "git@github.com:filmoteca/filmoteca.git"
set :scm, :git
set :keep_releases, 3
set :deploy_to, "/vagrant/#{fetch(:application)}"
set :compile_path, "uno/dos"
set :composer_install_flags, '--no-dev --no-interaction --quiet --optimize-autoloader --no-scripts'

# Example of invocation:
# cap production deploy BRANCH=2.0.1
#
set :branch, ENV['BRANCH'] if ENV['BRANCH']

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

SSHKit.config.command_map[:composer] = "php #{shared_path.join("composer.phar")}"

namespace :deploy do
  after :starting, 'composer:install_executable'
end

