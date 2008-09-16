namespace :bort do
  PLUGIN_LIST = {
    :acts_as_taggable_on_steroids => 'http://svn.viney.net.nz/things/rails/plugins/acts_as_taggable_on_steroids',
    :attachment_fu => 'git://github.com/technoweenie/attachment_fu.git',
    :bundle_fu => 'git://github.com/timcharper/bundle-fu.git',
    :haml => 'git://github.com/nex3/haml.git',
    :paperclip => 'git://github.com/thoughtbot/paperclip.git',
    :shoulda => 'git://github.com/thoughtbot/shoulda.git '
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
        system('script/plugin', 'install', value, '--force')
      end
    end
  end
end