namespace :bort do
  PLUGIN_LIST = {
    :paperclip => 'git://github.com/thoughtbot/paperclip.git'
  }
  
  desc 'List all plugins available to quick install'
  task :install do
    puts "\nAvailable Plugins\n=================\n\n"
    PLUGIN_LIST.each_pair do |key, value|
      puts "#{key.to_s.capitalize}: rake bort:install:#{key.to_s}\n"
    end
    puts "\n"
  end
  
  namespace :install do
    PLUGIN_LIST.each_pair do |key, value|
      task key do
        system('script/plugin', 'install', value)
      end
    end
  end
end