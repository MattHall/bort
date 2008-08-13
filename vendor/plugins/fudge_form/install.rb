puts "Copying file..."
dir = "initializers"
["fudge_form.rb"].each do |file|
  dest_file = File.join(RAILS_ROOT, "config", dir, file)
  src_file = File.join(File.dirname(__FILE__) , dir, file)
  FileUtils.cp_r(src_file, dest_file)
end
puts "File copied - Installation complete!"