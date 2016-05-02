set :application, "filmoteca"
set :repo_url,  "git@github.com:filmoteca/filmoteca.git"
set :scm, :git
set :keep_releases, 3
set :composer_install_flags, '--no-dev --no-interaction --quiet --optimize-autoloader --no-scripts'
set :uploads_dirs, %w(uploads resources)

# Example of invocation:
# cap production deploy BRANCH=2.0.1
#
set :branch, ENV['BRANCH'] if ENV['BRANCH']

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"
after "deploy:check:directories", "uploads:check:directories"
after "deploy:symlink:release", "uploads:symlink"

Rake::Task['deploy:updated'].prerequisites.delete('composer:install')

# A lambda function is required to set the correct value outside a task because the variables 
# (in this case shared_path) will have got the correct value after a command start. Otherwise
# the default or an empty value of the variable is get.
SSHKit.config.command_map[:composer] = -> { "LARAVEL_ENV=#{fetch(:stage)} php #{shared_path.join("composer.phar")}" }

namespace :deploy do
  after 	:starting, 		"composer:install_executable"
  before 	:publishing, 	"composer:install"
  before 	:publishing, 	"parameters:update"

  desc "Runs migrations"
  task :with_migrations do
    on roles(:app) do
    	after 	"parameters:update", "db:migrate"
    	invoke "deploy"
    end
  end
end

namespace :parameters do

	desc "Copy the parameters of stage the current release"
	task :update do
		on roles(:app) do
			execute "cp -R #{release_path}/../../app/config/#{fetch(:stage)} #{release_path}/app/config/"
		end
	end
end