module Zendesk

  module Helpers
    def zendesk_dropbox_config
      config = Zendesk.dropbox

      [:requester_email, :requester_name].each do |key|
        config = config.merge(key => instance_exec(&config[key])) if config[key].kind_of?(Proc)
      end

      javascript_tag("var zenbox_params = #{config.to_json};").html_safe
    end

    def zendesk_dropbox_tags
      return unless Zendesk.enabled?

      %(#{zendesk_dropbox_config}
      <style type='text/css' media='screen,projection'>@import url('#{Zendesk.css_asset_path}/#{Zendesk.css_asset_name}.css');</style>
      <script type='text/javascript' src='#{Zendesk.js_asset_path}/#{Zendesk.js_asset_name}.js'></script>).html_safe
    end

    def zendesk_link_to(text, options = {})
      return unless Zendesk.enabled?
      link_to text, support_path, options
    end

    def zendesk_dropbox_link_to(text)
      link_to text, '#', :onclick => 'Zenbox.render (); return false'
    end
  end

end
