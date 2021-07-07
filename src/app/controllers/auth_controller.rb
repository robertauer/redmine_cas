module Api
  module Cas
    class AuthController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :check_if_login_required

      def auth
        puts params
        render json: {
          "success": "yes"
        }
      end
    end
  end
end
