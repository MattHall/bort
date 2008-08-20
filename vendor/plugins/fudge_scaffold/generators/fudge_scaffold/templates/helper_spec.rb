require File.expand_path(File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../spec_helper')

describe Admin::<%= controller_class_name %>Helper do
  include Admin::<%= controller_class_name %>Helper
end
