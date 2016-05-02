# ==============================
# Database
# ==============================

namespace :db do

  task :migrate do 
    on roles(:app) do 
      execute "php #{release_path}/artisan migrate --env=#{fetch(:stage)}"
    end
  end
end