require File.dirname(__FILE__) + '/../../spec_helper'

describe "A template with an implicit helper", :type => :view do
  before(:each) do
    render "view_spec/implicit_helper"
  end

  it "should include the helper" do
    response.should have_tag('div', :content => "This is text from a method in the ViewSpecHelper")
  end

  it "should include the application helper" do
    response.should have_tag('div', :content => "This is text from a method in the ApplicationHelper")
  end

  it "should have access to named routes" do
    rspec_on_rails_specs_url.should == "http://test.host/rspec_on_rails_specs"
    rspec_on_rails_specs_path.should == "/rspec_on_rails_specs"
  end
end

describe "A template requiring an explicit helper", :type => :view do
  before(:each) do
    render "view_spec/explicit_helper", :helper => 'explicit'
  end

  it "should include the helper if specified" do
    response.should have_tag('div', :content => "This is text from a method in the ExplicitHelper")
  end

  it "should include the application helper" do
    response.should have_tag('div', :content => "This is text from a method in the ApplicationHelper")
  end
end

describe "A template requiring multiple explicit helpers", :type => :view do
  before(:each) do
    render "view_spec/multiple_helpers", :helpers => ['explicit', 'more_explicit']
  end

  it "should include all specified helpers" do
    response.should have_tag('div', :content => "This is text from a method in the ExplicitHelper")
    response.should have_tag('div', :content => "This is text from a method in the MoreExplicitHelper")
  end

  it "should include the application helper" do
    response.should have_tag('div', :content => "This is text from a method in the ApplicationHelper")
  end
end

describe "Message Expectations on helper methods", :type => :view do
  it "should work" do
    template.should_receive(:method_in_plugin_application_helper).and_return('alternate message 1')
    render "view_spec/implicit_helper"
    response.body.should =~ /alternate message 1/
  end

  it "should work twice" do
    template.should_receive(:method_in_plugin_application_helper).and_return('alternate message 2')
    render "view_spec/implicit_helper"
    response.body.should =~ /alternate message 2/
  end
end

describe "A template that includes a partial", :type => :view do
  def render!
    render "view_spec/template_with_partial"
  end

  it "should render the enclosing template" do
    render!
    response.should have_tag('div', "method_in_partial in ViewSpecHelper")
  end

  it "should render the partial" do
    render!
    response.should have_tag('div', "method_in_template_with_partial in ViewSpecHelper")
  end

  it "should include the application helper" do
    render!
    response.should have_tag('div', "This is text from a method in the ApplicationHelper")
  end
  
  it "should pass should_receive(:render) with the right partial" do
    template.should_receive(:render).with(:partial => 'partial')
    render!
    template.verify_rendered
  end
  
  it "should fail should_receive(:render) with the wrong partial" do
    template.should_receive(:render).with(:partial => 'non_existent')
    render!
    begin
      template.verify_rendered
    rescue Spec::Mocks::MockExpectationError => e
    ensure
      e.backtrace.find{|line| line =~ /view_spec_spec\.rb\:92/}.should_not be_nil
    end
  end
  
  it "should pass should_receive(:render) when a partial is expected twice and happens twice" do
    template.should_receive(:render).with(:partial => 'partial_used_twice').twice
    render!
    template.verify_rendered
  end
  
  it "should pass should_receive(:render) when a partial is expected once and happens twice" do
    template.should_receive(:render).with(:partial => 'partial_used_twice')
    render!
    begin
      template.verify_rendered
    rescue Spec::Mocks::MockExpectationError => e
    ensure
      e.backtrace.find{|line| line =~ /view_spec_spec\.rb\:109/}.should_not be_nil
    end
  end
  
  it "should fail should_receive(:render) with the right partial but wrong options" do
    template.should_receive(:render).with(:partial => 'partial', :locals => {:thing => Object.new})
    render!
    lambda {template.verify_rendered}.should raise_error(Spec::Mocks::MockExpectationError)
  end
end

describe "A partial that includes a partial", :type => :view do
  it "should support should_receive(:render) with nested partial" do
    obj = Object.new
    template.should_receive(:render).with(:partial => 'partial', :object => obj)
    render :partial => "view_spec/partial_with_sub_partial", :locals => { :partial => obj }
  end
end

describe "A view that includes a partial using :collection and :spacer_template", :type => :view  do
  it "should render the partial w/ spacer_tamplate" do
    render "view_spec/template_with_partial_using_collection"
    response.should have_tag('div',/method_in_partial/)
    response.should have_tag('div',/ApplicationHelper/)
    response.should have_tag('div',/ViewSpecHelper/)
    response.should have_tag('hr#spacer')
  end

  it "should render the partial" do
    template.should_receive(:render).with(:partial => 'partial',
               :collection => ['Alice', 'Bob'],
               :spacer_template => 'spacer')
    render "view_spec/template_with_partial_using_collection"
  end

end

if Rails::VERSION::MAJOR >= 2
  describe "A view that includes a partial using an array as partial_path", :type => :view do
    before(:each) do
      renderable_object = Object.new
      renderable_object.stub!(:name).and_return("Renderable Object")
      assigns[:array] = [renderable_object]
    end

    it "should render the array passed through to render_partial without modification" do
      render "view_spec/template_with_partial_with_array" 
      response.body.should match(/^Renderable Object$/)
    end
  end
end

describe "Different types of renders (not :template)", :type => :view do
  it "should render partial with local" do
    render :partial => "view_spec/partial_with_local_variable", :locals => {:x => "Ender"}
    response.should have_tag('div', :content => "Ender")
  end
end

describe "A view", :type => :view do
  before(:each) do
    session[:key] = "session"
    params[:key] = "params"
    flash[:key] = "flash"
    render "view_spec/accessor"
  end

  it "should have access to session data" do
    response.should have_tag("div#session", "session")
  end

  specify "should have access to params data" do
    response.should have_tag("div#params", "params")
  end

  it "should have access to flash data" do
    response.should have_tag("div#flash", "flash")
  end

  it "should have a controller param" do
    response.should have_tag("div#controller", "view_spec")
  end
  
  it "should have an action param" do
    response.should have_tag("div#action", "accessor")
  end
end

describe "A view with a form_tag", :type => :view do
  it "should render the right action" do
    render "view_spec/entry_form"
    response.should have_tag("form[action=?]","/view_spec/entry_form")
  end
end

describe "An instantiated ViewExampleGroupController", :type => :view do
  before do
    render "view_spec/foo/show"
  end
  
  it "should return the name of the real controller that it replaces" do
    @controller.controller_name.should == 'foo'
  end
  
  it "should return the path of the real controller that it replaces" do
    @controller.controller_path.should == 'view_spec/foo'
  end
end

describe "a block helper", :type => :view do
  it "should not yield when not told to in the example" do
    template.should_receive(:if_allowed)
    render "view_spec/block_helper"
    response.should_not have_tag("div","block helper was rendered")
  end

  it "should yield when told to in the example" do
    template.should_receive(:if_allowed).and_yield
    render "view_spec/block_helper"
    response.should have_tag("div","block helper was rendered")
  end
end

describe "render :inline => ...", :type => :view do
  it "should render ERB right in the spec" do
    render :inline => %|<%= text_field_tag('field_name', 'Value') %>|
    response.should have_tag("input[type=?][name=?][value=?]","text","field_name","Value")
  end
end

describe "render 'view_spec/foo/show.rhtml'", :type => :view do
  it "should derive action name using the first part of the template name" do
    render 'view_spec/foo/show.rhtml'
    request.path_parameters[:action].should == 'show'
  end
end

module Spec
  module Rails
    module Example
      describe ViewExampleGroup do
        it "should clear its name from the description" do
          group = describe("foo", :type => :view) do
            $nested_group = describe("bar") do
            end
          end
          group.description.to_s.should == "foo"
          $nested_group.description.to_s.should == "foo bar"
        end

        it "should clear ActionView::Base.base_view_path on teardown" do
          group = describe("base_view_path_cleared flag", :type => :view) {}
          example = group.it{}
          
          ActionView::Base.should_receive(:base_view_path=).with(nil)
          group.run_after_each(example)
        end
      end
    end
  end
end

describe "bug http://rspec.lighthouseapp.com/projects/5645/tickets/510", :type => :view do
  describe "a view example with should_not_receive" do
    it "should render the view" do
      obj = mock('model')
      obj.should_receive(:render_partial?).and_return false
      assigns[:obj] = obj
      template.should_not_receive(:render).with(:partial => 'some_partial')
      render "view_spec/should_not_receive"
    end
  end
end
