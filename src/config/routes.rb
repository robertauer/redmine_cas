RedmineApp::Application.routes.draw do
  get 'cas', :to => 'account#cas'
  post 'cas', :to => 'account#cas'

  namespace :api do
    namespace :cas do
      post 'auth', action: :auth, controller: 'auth'
    end
  end
end
