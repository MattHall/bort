module ApplicationHelper
  
  def title(str, container = nil)
    @page_title = str
    container_tag(container, str) if container
  end
  
end
