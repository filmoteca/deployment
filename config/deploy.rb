set :application, "filmoteca"
set :repo_url,  "git@github.com:filmoteca/filmoteca.git"
set :keep_releases, 2
set :composer_install_flags, '--no-interaction --quiet --optimize-autoloader --no-scripts'
set :linked_dirs, [
    'app/storage/logs',
    'app/storage/sessions',
    'htdocs/mirada',
    'htdocs/MUVAC',
    'htdocs/cinelinea',
    'htdocs/resources',
    'htdocs/uploads'
]

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
    before  :publishing,    "deploy:set_permissions"
    after   :publishing,    "db:migrate"

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
                Rake::Task["composer:run"].reenable
                invoke "composer:run", "run-script", "publish-assets --no-dev --working-dir=#{fetch(:release_path)}"
            end
        end
    end

    desc "Sets correct permissions"
    task :set_permissions do
        on roles(:app) do
            directories = [
                'app/storage/logs',
                'app/storage/sessions',
                'app/storage/views',
                'app/storage/cache',
                'htdocs/resources',
                'htdocs/uploads'
            ]

            directories.each do |directory|
                execute :sudo, :chown, "www-data:#{fetch(:ssh_user)} -R #{fetch(:release_path)}/#{directory}"
            end
        end
    end
end
