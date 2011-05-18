module Zendesk

  module Routing
    def zendesk(options = {})
      return unless Zendesk.enabled?

      base = options[:on] || '/zendesk'
      ctrl = options[:controller]

      unless ctrl.present?
        raise ConfigurationError, "Missing :controller option"
      end

      scope base.to_s, :controller => ctrl do
        get '/',     :action => :zendesk_login,  :as => base.to_sym
        get '/exit', :action => :zendesk_logout, :as => nil
      end

      # Install the methods into the given controller
      "#{ctrl.camelize}Controller".constantize.instance_eval { include Controller }
    end
  end

end
