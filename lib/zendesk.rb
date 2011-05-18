require 'digest/md5'

require 'zendesk/controller'
require 'zendesk/helpers'
require 'zendesk/routing'
require 'zendesk/version'
require 'zendesk/railtie'

# Zendesk remote authentication helper for Rails. Implements JS generation,
# controller actions and route helpers. Have a look at the code, because it
# is more explanatory than a thousand words :-)
#
# Kudos to the Zendesk staff for such a simple and effective interface.
#
# (C) 2010 Panmind, Released under the terms of the Ruby License.
# (C) 2011 vjt@openssl.it
#
#   - vjt  Wed May 18 23:01:09 CEST 2011
#
module Zendesk
  class ConfigurationError < StandardError; end

  class << self
    attr_reader :token, :hostname

    def auth_url;    @auth_url    ||= "http://#{hostname}/access/remote/".freeze end
    def return_url;  @return_url  ||= "http://#{hostname}/login".freeze          end
    def support_url; @support_url ||= "http://#{hostname}/home".freeze           end

    # TODO these should become attr_readers and we set @variables directly
    attr_accessor :dropbox, :login, :login_url, :js_asset_path, :js_asset_name, :css_asset_path, :css_asset_name

    def check_configuration!
      options = Rails.application.config.zendesk rescue nil

      unless options.present?
        raise ConfigurationError, "Zendesk configuration missing! Please define config.zendesk"
      end

      self.token, self.hostname, self.login, self.login_url =
        options.values_at(:token, :hostname, :login, :login_url)

      if %w( token hostname login login_url ).any? {|conf| send(conf).blank?}
        raise ConfigurationError, "Zendesk requires the API token, an hostname a proc to infer the user name "\
                                  "and e-mail and the login route helper name" # TODO don't require all these things
      end

      # Dropbox specific customizations, defaults in place
      self.dropbox = (options[:dropbox] || {}).reverse_merge(
        :dropboxID => 'feedback',
        :url       => Zendesk.hostname
      ).freeze

      # Path and name for css and asset required for zenbox 2.0
      self.js_asset_path  = options[:js_asset_path]  || '//assets0.zendesk.com/external/zenbox'
      self.js_asset_name  = options[:js_asset_name]  || 'zenbox-2.0'
      self.css_asset_path = options[:css_asset_path] || '//assets0.zendesk.com/external/zenbox'
      self.css_asset_name = options[:css_asset_name] || 'zenbox-2.0'
    end

    def enabled?
      # FIXME we should not disable this code in the
      # test environment, rather test it appropriately
      Rails.env.production? || Rails.env.development?
    end

    private
      def token=(token);       @token    = token.freeze    rescue nil end
      def hostname=(hostname); @hostname = hostname.freeze            end
  end

end
