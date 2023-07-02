Rails.application.routes.draw do

  get 'users' => 'users#index'
  get 'users/:user_id' => 'users#show'
  get 'users/:user_id/groups' => 'users#show_joined_groups'
  get 'users/:user_id/groups/ids' => 'users#show_joined_group_ids'
  get 'users/:user_id/groups/simple' => 'users#show_joined_groups_simple'
  get 'users/new' => 'users#new'
  post 'users' => 'users#create'
  get 'users/:id/edit' => 'users#edit'
  patch 'users/:user_id'  => 'users#update'
  delete 'users/:user_id' => 'users#destroy'

  get '/signup', to: 'users#sign_up'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :groups
  patch '/groups/:id/participate', to: 'groups#participate'
  patch '/groups/:id/leave', to: 'groups#leave'
  get '/groups/:id/chat', to: 'groups#chat_group'
  get '/groups/locations/count', to: 'groups#group_count_by_area'

  get 'maps/search_individual' => 'maps#search_individual'
  get 'maps/search_by_text' => 'maps#search_by_text'
  get 'maps/search_nearby' => 'maps#search_nearby'
  get 'maps/place_detail' => 'maps#fetch_place_detail'

  get 'events' => 'events#index'
  post 'events' => 'events#create'
  get 'events/:id' => 'events#show'
  patch 'events/:id/register' => 'events#register'
  patch 'events/:id/unregister' => 'events#unregister'
  delete 'events/:id' => 'events#destroy'

  resource :github_webhooks, only: :create, defaults: { formats: :json }
end
