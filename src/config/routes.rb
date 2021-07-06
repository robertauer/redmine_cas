RedmineApp::Application.routes.draw do
  get 'cas', :to => 'account#cas'
  post 'cas', :to => 'account#cas'
  get 'cas/auth', action: :auth, controller: 'auth'
end
