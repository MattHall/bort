require File.dirname(__FILE__) + '/../spec_helper'
include ApplicationHelper
include AuthenticatedTestHelper

describe ApplicationHelper do
  
  describe "title" do
    it "should set @page_title" do
      title('hello').should be_nil
      @page_title.should eql('hello')
    end
    
    it "should output container if set" do
      title('hello', :h2).should have_tag('h2', 'hello')
    end
  end
  
end