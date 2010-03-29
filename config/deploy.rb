####################################################
# APP OPTIONS
####################################################
set :application, "lococare"
set :deploy_to, "/home/lee/public_html/#{application}"

####################################################
# SOURCE CONTROL
####################################################
set :scm,           :git
set :repository,  "file:///var/git/#{application}.git/"
set :git_enable_submodules, 1
set :local_repository,   "#{File.dirname(__FILE__)}/../"
set :branch, "master"
set :keep_releases, 2
set :deploy_via,    :remote_cache
set :paranoid,      false
set :use_sudo,       false


####################################################
# ROLES
####################################################
role :app, "leepope.com"
role :web, "leepope.com"
role :db,  "leepope.com", :primary => true

####################################################
# HOOKS
####################################################
after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:update_code", "deploy:symlink_configs"
# after "deploy:update_code", "gems:symlink_gems_cache"
# after "deploy:update_code", "gems:bundle"

####################################################
# SSH OPTIONS
####################################################
ssh_options[:port] = 8888

namespace :deploy do
  desc "After update_code you want to symlink the index and ferret_server.yml file into place"
  task :symlink_configs, :roles => :app, :except => {:no_release => true} do
    run <<-CMD
      cd #{release_path} &&
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/ &&
      ln -nfs #{shared_path}/config/session_store.rb #{release_path}/config/initializers/ &&
      ln -nfs #{shared_path}/config/email.yml #{release_path}/config/
    CMD
  end

  desc "Restart the Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  #desc "Bundle gems"
  #task :bundle_gems, :roles => :app do
  #  gemfile = "#{shared_path}/Gemfile"
  #  run <<-CMD
  #    
  #    cd #{release_path}
  #    cp Gemfile #{shared_path}
  #    echo "bundle_path \"#{shared_path/vendor/gems}\"" >> #{gemfile}
  #    gem bundle -u -m #{gemfile}
  #    rm #{current_path}/vendor/gems
  #    ln -s #{shared_path}/vendor/gems #{current_path}/vendor/gems
  #  CMD
  #end
end

# symlink to the shared gem-cache path then bundle our gems
namespace :gems do
  task :symlink_gems_cache do
    run "ln -nfs #{shared_path}/bundler_gems/cache #{current_path}/vendor/gems/cache"
  end
  task :bundle, :roles => :app do
    run "cd #{current_path} && gem bundle --update"
  end
end
