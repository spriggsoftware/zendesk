module Zendesk

  module Routing
    def zendesk(base, options = {})
      return unless Zendesk.enabled?

      scope base.to_s, :controller => options[:controller] do
        get '',     :action => :zendesk_login,  :as => base.to_sym
        get 'exit', :action => :zendesk_logout, :as => nil
      end
    end
  end

end
