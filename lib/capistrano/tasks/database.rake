# ==============================
# Database
# ==============================

namespace :db do

  desc "Run migration. Those in the packages, too."
  task :migrate do 
  	Rake::Task["composer:run"].reenable
    invoke "composer:run", "run-script", "migrate --no-dev --working-dir=#{fetch(:release_path)}"
  end
end