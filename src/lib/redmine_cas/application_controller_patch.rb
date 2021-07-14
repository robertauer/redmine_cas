require 'redmine_cas'

module RedmineCAS
  module ApplicationControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :verify_authenticity_token_without_cas, :verify_authenticity_token
        alias_method :verify_authenticity_token, :verify_authenticity_token_with_cas
        alias_method :require_login_without_cas, :require_login
        alias_method :require_login, :require_login_with_cas
        alias_method :original_check_if_login_required, :check_if_login_required
        alias_method :check_if_login_required, :cas_check_if_login_required

        alias_method :original_find_current_user, :find_current_user
        alias_method :find_current_user, :cas_find_current_user
      end
    end

    module InstanceMethods

      def cas_find_current_user
        if /\AProxyTicket /i.match?(request.authorization.to_s)
          ticket = request.authorization.to_s.split(" ", 2)[1]
          response = validate(ticket)

          if (Nokogiri::XML(response.body).xpath('//cas:serviceResponse').to_s).include? 'Success'
            userAttributes = Nokogiri::XML(response.body)
            login = userAttributes.at_xpath('//cas:authenticationSuccess//cas:attributes//cas:cn').content.to_s
            user = User.find_by_login(login)

            if user == nil
              userAttributes = Nokogiri::XML(response.body)
              user_mail = userAttributes.at_xpath('//cas:authenticationSuccess//cas:attributes//cas:mail').content.to_s
              user_surname = userAttributes.at_xpath('//cas:authenticationSuccess//cas:attributes//cas:surname').content.to_s
              user_givenName = userAttributes.at_xpath('//cas:authenticationSuccess//cas:attributes//cas:givenName').content.to_s
              user_groups = userAttributes.xpath('//cas:authenticationSuccess//cas:attributes//cas:groups')
              cas_auth_source = AuthSource.find_by(:name => 'Cas')
              user = AuthSourceCas.create_or_update_user(login, user_givenName, user_surname, user_mail, user_groups, cas_auth_source.id)
            end

            return user
          end
        end

        return original_find_current_user
      end

      def validate(ticket)
        params = { :ticket => ticket, :service => "https://#{FQDN}/redmine/api/cas/auth" }
        uri = "https://#{FQDN}/cas/p3/proxyValidate"

        http_uri = URI.parse(uri)
        http_uri.query = URI.encode_www_form(params)

        http = Net::HTTP.new(http_uri.host, http_uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new("#{http_uri.path}?#{http_uri.query}")
        http.request(request)
      end

      def require_login_with_cas
        return require_login_without_cas unless RedmineCAS.enabled?

        if !User.current.logged?
          referrer = request.fullpath;
          respond_to do |format|
            # pass referer to cas action, to work around this problem:
            # https://github.com/ninech/redmine_cas/pull/13#issuecomment-53697288
            format.html { redirect_to :controller => 'account', :action => 'cas', :ref => referrer }
            format.atom { redirect_to :controller => 'account', :action => 'cas', :ref => referrer }
            format.xml { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"' }
            format.js { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"' }
            format.json { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"' }
          end
          return false
        end
        # this code was added to remove the ticket parameter in url when it is not necessary
        if params.has_key?(:ticket)
          default_url = url_for(params.permit(:ticket).merge(:ticket => nil))
          redirect_to default_url
        end
        true
      end

      def cas_check_if_login_required
        return original_check_if_login_required unless RedmineCAS.enabled?
        require_login if params.has_key?(:ticket) or original_check_if_login_required
      end

      def verify_authenticity_token_with_cas
        if cas_logout_request?
          logger.info 'CAS logout request detected: Skipping validation of authenticity token'
        else
          verify_authenticity_token_without_cas
        end
      end

      def cas_logout_request?
        request.post? && params.has_key?('logoutRequest')
      end

    end
  end
end
