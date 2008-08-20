class FudgeScaffoldGenerator < Rails::Generator::NamedBase
  # Default Options
  default_options :skip_timestamps => false, :skip_migration => false

  # Attributes
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name,
                :resource_edit_path,
                :default_file_extension
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name

  # Initialise
  def initialize(runtime_args, runtime_options = {})
    super
    
    # Find controller name
    @controller_name = @name.pluralize

    # Set generator variables
    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name = base_name.singularize
    
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
    
    # Find erb extension
    if Rails::VERSION::STRING < "2.0.0"
      @resource_generator = "scaffold_resource"
      @default_file_extension = "rhtml"
		else
      @resource_generator = "scaffold"
      @default_file_extension = "html.erb"
    end
  end

  # Manifest
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
      m.class_collisions(class_path, "#{class_name}")

      # Controller, helper, views, test and stylesheets directories.
      m.directory(File.join('app/models', class_path))
      m.directory(File.join('app/controllers/admin', controller_class_path))
      m.directory(File.join('app/helpers/admin/', controller_class_path))
      m.directory(File.join('app/views/admin', controller_class_path, controller_file_name))
      
      # Spec directories
      m.directory(File.join('spec/controllers/admin', controller_class_path))
      m.directory(File.join('spec/models', class_path))
      m.directory(File.join('spec/helpers/admin', class_path))
      m.directory File.join('spec/fixtures', class_path)
      m.directory File.join('spec/views/admin', controller_class_path, controller_file_name)

      # Create scaffold views
      for action in scaffold_views
        m.template(
          "view_#{action}.html.erb",
            File.join('app/views/admin', controller_class_path, controller_file_name, "#{action}.html.erb")
        )
      end
      
      # Create object partial
      m.template('view__partial.html.erb', 
        File.join('app/views/admin', controller_class_path, controller_file_name, "_#{class_name.downcase}.html.erb"))

      # Create controller
      m.template('controller.rb', 
        File.join('app/controllers/admin', controller_class_path, "#{controller_file_name}_controller.rb"))

      # Create helper
      m.template('helper.rb', 
        File.join('app/helpers/admin', controller_class_path, "#{controller_file_name}_helper.rb"))
      m.dependency 'model', [name] + @args, :collision => :skip
      
      # Create controller/helper specs
      m.template 'routing_spec.rb',
        File.join('spec/controllers/admin', controller_class_path, "#{controller_file_name}_routing_spec.rb")

      m.template 'controller_spec.rb',
        File.join('spec/controllers/admin', controller_class_path, "#{controller_file_name}_controller_spec.rb")

      m.template 'helper_spec.rb',
        File.join('spec/helpers/admin', class_path, "#{controller_file_name}_helper_spec.rb")
        
      # Model class, unit test, and fixtures.
      m.template 'model:fixtures.yml', File.join('spec/fixtures', class_path, "#{table_name}.yml")
      m.template 'model_spec.rb', File.join('spec/models', class_path, "#{file_name}_spec.rb")

      # View specs
      m.template "edit_erb_spec.rb",
        File.join('spec/views/admin', controller_class_path, controller_file_name, "edit.#{default_file_extension}_spec.rb")
      m.template "index_erb_spec.rb",
        File.join('spec/views/admin', controller_class_path, controller_file_name, "index.#{default_file_extension}_spec.rb")
      m.template "new_erb_spec.rb",
        File.join('spec/views/admin', controller_class_path, controller_file_name, "new.#{default_file_extension}_spec.rb")
        
      m.route_resources controller_file_name
    end
  end

  protected
  
  # Useage
  def banner
    "Usage: #{$0} fudge_scaffold ModelName [field:type, field:type]"
  end

  # Generator options
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-timestamps", "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
    opt.on("--skip-migration", "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
  end

  def scaffold_views
    %w[ index new edit _form ]
  end

  def model_name
    class_name.demodulize
  end
end

module Rails
  module Generator
    class GeneratedAttribute
      def default_value
        @default_value ||= case type
          when :int, :integer then "\"1\""
          when :float then "\"1.5\""
          when :decimal then "\"9.99\""
          when :datetime, :timestamp, :time then "Time.now"
          when :date then "Date.today"
          when :string then "\"MyString\""
          when :text then "\"MyText\""
          when :boolean then "false"
          else ""
        end      
      end

      def input_type
        @input_type ||= case type
          when :text then "textarea"
          else "input"
        end      
      end
    end
  end
end
