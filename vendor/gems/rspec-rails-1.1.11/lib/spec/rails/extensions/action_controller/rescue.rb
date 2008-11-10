module ActionController
  module Rescue
    def use_rails_error_handling!
      @use_rails_error_handling = true
    end

    def use_rails_error_handling?
      @use_rails_error_handling ||= false
    end

    protected
    def rescue_action_with_fast_errors(exception)
      if use_rails_error_handling?
        rescue_action_without_fast_errors exception
      else
        raise exception
      end
    end
    alias_method_chain :rescue_action, :fast_errors
  end
end
