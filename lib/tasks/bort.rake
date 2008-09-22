namespace :bort do
  PLUGIN_LIST = {
    :acts_as_taggable_on_steroids => 'http://svn.viney.net.nz/things/rails/plugins/acts_as_taggable_on_steroids',
    :attachment_fu => 'git://github.com/technoweenie/attachment_fu.git',
    :bundle_fu => 'git://github.com/timcharper/bundle-fu.git',
    :fudge_form => 'git://github.com/JimNeath/fudge_form.git',
    :haml => 'git://github.com/nex3/haml.git',
    :jrails => 'git://github.com/aaronchi/jrails.git',
    :open_id_authentication => 'git://github.com/rails/open_id_authentication.git',
    :paperclip => 'git://github.com/thoughtbot/paperclip.git',
    :salty_slugs => 'git://github.com/norbauer/salty_slugs.git',
    :shoulda => 'git://github.com/thoughtbot/shoulda.git',
    :spawn => 'git://github.com/tra/spawn.git',
    :workling => 'git://github.com/purzelrakete/workling.git'
  }
  
  desc 'List all plugins available to quick install'
  task :install do
    puts "\nAvailable Plugins\n=================\n\n"
    plugins = PLUGIN_LIST.keys.sort_by { |k| k.to_s }.map { |key| [key, PLUGIN_LIST[key]] }
    
    plugins.each do |plugin|
      puts "#{plugin.first.to_s.gsub('_', ' ').capitalize.ljust(30)} rake bort:install:#{plugin.first.to_s}\n"
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