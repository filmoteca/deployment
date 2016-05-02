# ==============================
# Database
# ==============================

namespace :db do

  task :migrate do 
  	invoke "composer:run", "run-script", "migrate --no-dev --working-dir=#{fetch(:deploy_to)}/current"
  end
end