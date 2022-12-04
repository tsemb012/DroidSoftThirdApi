Rails.application.routes.draw do
  resources :groups
  get 'users' => 'users#index'
  get 'users/:user_id' => 'users#show'
  get 'users/new' => 'users#new'
  post 'users' => 'users#create'
  get 'users/:id/edit' => 'users#edit'
  patch 'users/:user_id'  => 'users#update'
  delete 'users/:user_id' => 'users#destroy'
  get '/signup', to: 'users#sign_up'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  patch '/groups/:id/participate', to: 'groups#participate'
  get 'maps' => 'maps#show'
end
