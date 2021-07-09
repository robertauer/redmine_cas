require 'net/http'
require 'net/https'

FQDN = ENV['FQDN']

module Api
  module Cas
    class AuthController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :check_if_login_required

      def auth
        response = validate(params['ticket'])

        if (Nokogiri::XML(response.body).xpath('//cas:serviceResponse').to_s).include? 'Success'
          userAttributes = Nokogiri::XML(response.body)
          login = userAttributes.at_xpath('//cas:authenticationSuccess//cas:attributes//cas:cn').content.to_s
          user = User.find_by_login(login)
          render json: {
            "login": user.login,
            "token": user.api_key
          }
        else
          render status: 405, json: { "error": response.body }
        end

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
    end
  end
end
