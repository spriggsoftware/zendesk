module Zendesk

  module Controller
    extend ActiveSupport::Concern

    included do
      before_filter :zendesk_handle_guests, :only => :zendesk_login
    end

    def zendesk_login
      name, email = instance_exec(&Zendesk.login)

      now  = params[:timestamp] || Time.now.to_i.to_s
      hash = Digest::MD5.hexdigest(name + email + Zendesk.token + now)
      back = params[:return_to] || Zendesk.return_url

      auth_params = [
        '?name='      + CGI.escape(name),
        '&email='     + CGI.escape(email),
        '&timestamp=' + now,
        '&hash='      + hash,
        '&return_to=' + back
      ].join

      redirect_to(Zendesk.auth_url + auth_params)
    end

    def zendesk_logout
      flash[:notice] = "Thanks for visiting our support forum."
      redirect_to root_url
    end

    private
      def zendesk_handle_guests
        return if logged_in? rescue false # TODO add another option

        if params[:timestamp] && params[:return_to]
          # User clicked on Zendesk "login", thus redirect to our
          # login page, that'll redirect him/her back to Zendesk.
          #
          redirect_to send(Zendesk.login_url, :return_to => support_url)
        else
          # User clicked on our "support" link, and maybe doesn't
          # have an account yet: redirect him/her to the support.
          #
          redirect_to Zendesk.support_url
        end
      end
  end

end
