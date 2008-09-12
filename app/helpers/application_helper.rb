module ApplicationHelper
  
  # Sets the page title and outputs title if container is passed in.
  # eg. <%= title('Hello World', :h2) %> will return the following:
  # <h2>Hello World</h2> as well as setting the page title.
  def title(str, container = nil)
    @page_title = str
    content_tag(container, str) if container
  end
  
  # Outputs the corresponding flash message if any are set
  def flash_messages
    message = content_tag(:div, flash[:notice], :id => 'flash-notice') unless flash[:notice].blank?
    message = content_tag(:div, flash[:warning], :id => 'flash-warning') unless flash[:warning].blank?
    message = content_tag(:div, flash[:error], :id => 'flash-error') unless flash[:error].blank?
    message
  end
  
end
