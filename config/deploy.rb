set :application, "filmoteca"
set :repo_url,  "git@github.com:filmoteca/filmoteca.git"
set :scm, :git
set :user, 'www-data'
set :keep_releases, 3
set :composer_install_flags, '--no-dev --no-interaction --quiet --optimize-autoloader --no-scripts'
set :linked_dirs, fetch(:linked_dirs, []) + %w{app/storage/logs app/storage/sessions htdocs/resources htdocs/uploads}

# Example of invocation:
# cap production deploy BRANCH=2.0.1
#
set :branch, ENV['BRANCH'] if ENV['BRANCH']

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart",           "deploy:cleanup"

Rake::Task['deploy:updated'].prerequisites.delete('composer:install')

# A lambda function is required to set the correct value outside a task because the variables 
# (in this case shared_path) will have got the correct value after a command start. Otherwise
# the default or an empty value of the variable is get.
SSHKit.config.command_map[:composer] = -> { "LARAVEL_ENV=#{fetch(:stage)} #{fetch(:php)} #{shared_path.join("composer.phar")}" }

namespace :deploy do
    after   :starting,      "composer:install_executable"
    before  :publishing,    "composer:install"
    before  :publishing,    "deploy:assets:upload"
    before  :publishing,    "parameters:update"
    after   :publishing,    "db:migrate"
    before  :cleanup,       "deploy:remove_linked_dirs"

    namespace :assets do 

        desc "Builds the assets and copy them to local directory"
        task :build do 
            run_locally do
                execute "rm -Rf tmp"
                execute "git clone #{fetch(:repo_url)} tmp#{release_path} -b #{fetch(:branch)}"
                execute "cd tmp#{release_path} && bower install"
                execute "sass --update --force tmp#{release_path}/htdocs/assets/sass:tmp#{release_path}/htdocs/assets/css"
                execute "cd tmp#{release_path} && tar -cf assets.tar htdocs/assets/css htdocs/bower_components"
                execute "gzip tmp#{release_path}/assets.tar"
            end
        end

        desc "Copies the built assets to the stage"
        task :upload => [:publish_packages, :build] do
            on roles(:app) do
                upload!("tmp#{release_path}/assets.tar.gz", "#{release_path}")
                execute "rm -rf #{release_path}/assets.tar"
                execute "cd #{release_path} && gunzip assets.tar.gz && tar -xf assets.tar"
            end
        end

        desc "Publish the assets of other packages"
        task :publish_packages do
            on roles(:app) do
                puts "Publishing assets of the packages"
                Rake::Task["composer:run"].reenable
                invoke "composer:run", "run-script", "publish-assets --no-dev --working-dir=#{fetch(:release_path)}"
            end
        end
    end

    desc "Remove the linked directories so its content is not removed when a release is deleted"
    task :remove_linked_dirs do
        on roles(:app) do
            oldest_release = capture(:ls, "-xtr", releases_path).split.first
            older_release_path = "#{releases_path}/#{oldest_release}"
            fetch(:linked_dirs).map do |d| 
                if File.exists?("#{older_release_path}/#{d}")
                    puts "Removing #{older_release_path}/#{d}"
                    execute "rm #{older_release_path}/#{d}"
                end
            end
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
