module ApplicationHelper
  
  def title(str, container = nil)
    @page_title = str
    content_tag(container, str) if container
  end
  
end
