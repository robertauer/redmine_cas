class AuthController < ApplicationController
  accept_api_auth :auth

  def auth
    render json: {
      "execution": "success"
    }
  end
end
