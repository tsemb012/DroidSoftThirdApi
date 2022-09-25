Rails.application.routes.draw do
  resources :groups
  resources :users
  get '/signup', to: 'users#sign_up'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  patch '/groups/:id/participate', to: 'groups#participate'
end
