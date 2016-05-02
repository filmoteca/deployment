# ==============================
# Uploads
# ==============================
# 
# Original Author: Simone Carletti
# Reference: https://simonecarletti.com/blog/2009/02/capistrano-uploads-folder/
# 

namespace :uploads do

  namespace :check do

    desc "Creates the upload folders unless they exist and sets the proper upload permissions."
    task :directories do
      on roles(:app) do
        dirs = fetch(:uploads_dirs).map { |d| File.join(shared_path, d) }
        execute "mkdir -p #{dirs.join(' ')} && chmod g+w #{dirs.join(' ')}"
      end
    end
    
  end

  desc "[internal] Creates the symlink to uploads shared folder for the most recently deployed version."
  task :symlink do
    on roles(:app) do
      fetch(:uploads_dirs).map do |d|
        execute "rm -rf #{release_path}/htdocs/#{d}"
        execute "ln -nfs #{shared_path}/#{d} #{release_path}/htdocs/#{d}"
      end 
    end
  end
end