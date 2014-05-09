TeamDeweyWebsite::Application.routes.draw do
  resources :friendships do
    get "friends"
  end

  get "sessions/login"
  get "sessions/google_api"

  get "sessions/mixpanel_id"
  get "sessions/get_auth_token"
  post "sessions/post_login"
  post "sessions/post_try_facebook_login"
  post "sessions/post_facebook_login"
  post "sessions/register"
  get "sessions/get_users"
  get "users/index"
  get "topics/most_connected"

  post "users/add_friends"
  get "about/team"
  get "graphs/search"
  post "users/import_google_contacts"

  resources :graphs

  resources :topics do
    post "add_connection"
    post "remove_connection"
    post "create"
    get "most_connected"
    get "related"
    
    get "user_suggestions"
    post "add_user"
    post "remove_user"

    resources :users

  end

  resources :users do
    post "add_topic"

    post "remove_topic"
    get "most_connected"
    get "topic_suggestions"

    resources :topics

  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'users#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
