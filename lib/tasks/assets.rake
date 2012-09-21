namespace :assets do
  namespace :js do
    desc 'Compile all js files'
    task :compile do
      system("#{Rails.root}/script/buildjs")
    end

    desc 'Watch assets files and automatically recompile on change'
    task :watch do
      system("#{Rails.root}/script/watchjs")
    end
  end
end
