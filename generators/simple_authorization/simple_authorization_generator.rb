class SimpleAuthorizationGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.migration_template "model:migration.rb", "db/migrate", :assigns => simple_auth_assigns,
        :migration_file_name => "create_#{custom_file_name}" if options[:migration]
    end
  end

private

  def custom_file_name
    name = class_name.underscore.downcase
    name = name.pluralize if ActiveRecord::Base.pluralize_table_names
    name
  end

  def simple_auth_assigns
    {
      :migration_name => "Create#{custom_file_name.camelize}",
      :table_name => custom_file_name,
      :attributes => simple_auth_attributes
    }
  end

  def simple_auth_attributes
    returning attributes.dup do |attributes|
      {"name" => "string", "description" => "text", "identifier" => "string", "user" => "belongs_to"}.each do |name, type|
        attributes << Rails::Generator::GeneratedAttribute.new(name, type) unless attributes.any?{|a| a.name == name }
      end
    end
  end

  def add_options!(opt)
    opt.on('--migration', 'Create migration'){|v| options[:migration] = true }
  end

end
