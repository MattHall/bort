module FudgeFormHelper
      
  def wrapping(type, field_name, label, field, options = {})
    help = %Q{<small>#{options[:help]}</small>} if options[:help]
    to_return = []
    to_return << %Q{<li class="#{options[:class]}">}
    to_return << %Q{<label for="#{field_name}">#{label}</label>} unless ["radio","check", "submit"].include?(type)
    to_return << field
    to_return << %Q{<label for="#{field_name}">#{label}</label>} if ["radio","check"].include?(type)
    to_return << %Q{#{help}</li>}
  end
 
  def semantic_group(type, field_name, label, fields, options = {})
    help = %Q{<span class="help">#{options[:help]}</span>} if options[:help]
    to_return = []
    to_return << %Q{<li><fieldset class="#{options[:class]}">}
    to_return << %Q{<legend>#{label}</legend>}
    to_return << %Q{<ol>}
    to_return << fields.join("\n")
    to_return << %Q{</ol></fieldset></li>}
  end
 
  def boolean_field_wrapper(input, name, value, text, help = nil)
    field = []
    field << %Q{<li><label>#{input} #{text}</label>}
    field << %Q{<small>#{help}</small>} if help
    field << %Q{</li>}
    field
  end
  
  def field_set(legend = nil, &block)
    content = @template.capture(&block)
    @template.concat(@template.tag(:fieldset, {}, true), block.binding)
    @template.concat(@template.content_tag(:legend, legend), block.binding) unless legend.blank?
    @template.concat(@template.tag(:ol, {}, true), block.binding)
    @template.concat(content, block.binding)
    @template.concat("</ol></fieldset>", block.binding)
  end
 
end