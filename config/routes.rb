# == Route Map (Updated 2014-06-07 02:05)
#
#                           Prefix Verb   URI Pattern                                   Controller#Action
#               friendship_friends GET    /friendships/:friendship_id/friends(.:format) friendships#friends
#                      friendships GET    /friendships(.:format)                        friendships#index
#                                  POST   /friendships(.:format)                        friendships#create
#                   new_friendship GET    /friendships/new(.:format)                    friendships#new
#                  edit_friendship GET    /friendships/:id/edit(.:format)               friendships#edit
#                       friendship GET    /friendships/:id(.:format)                    friendships#show
#                                  PATCH  /friendships/:id(.:format)                    friendships#update
#                                  PUT    /friendships/:id(.:format)                    friendships#update
#                                  DELETE /friendships/:id(.:format)                    friendships#destroy
#                   sessions_login GET    /sessions/login(.:format)                     sessions#login
#              sessions_google_api GET    /sessions/google_api(.:format)                sessions#google_api
#             sessions_mixpanel_id GET    /sessions/mixpanel_id(.:format)               sessions#mixpanel_id
#          sessions_get_auth_token GET    /sessions/get_auth_token(.:format)            sessions#get_auth_token
#              sessions_post_login POST   /sessions/post_login(.:format)                sessions#post_login
# sessions_post_try_facebook_login POST   /sessions/post_try_facebook_login(.:format)   sessions#post_try_facebook_login
#     sessions_post_facebook_login POST   /sessions/post_facebook_login(.:format)       sessions#post_facebook_login
#                sessions_register POST   /sessions/register(.:format)                  sessions#register
#               sessions_get_users GET    /sessions/get_users(.:format)                 sessions#get_users
#                      users_index GET    /users/index(.:format)                        users#index
#            topics_most_connected GET    /topics/most_connected(.:format)              topics#most_connected
#                users_add_friends POST   /users/add_friends(.:format)                  users#add_friends
#                       about_team GET    /about/team(.:format)                         about#team
#                    graphs_search GET    /graphs/search(.:format)                      graphs#search
#     users_import_google_contacts POST   /users/import_google_contacts(.:format)       users#import_google_contacts
#                           graphs GET    /graphs(.:format)                             graphs#index
#                                  POST   /graphs(.:format)                             graphs#create
#                        new_graph GET    /graphs/new(.:format)                         graphs#new
#                       edit_graph GET    /graphs/:id/edit(.:format)                    graphs#edit
#                            graph GET    /graphs/:id(.:format)                         graphs#show
#                                  PATCH  /graphs/:id(.:format)                         graphs#update
#                                  PUT    /graphs/:id(.:format)                         graphs#update
#                                  DELETE /graphs/:id(.:format)                         graphs#destroy
#             topic_add_connection POST   /topics/:topic_id/add_connection(.:format)    topics#add_connection
#          topic_remove_connection POST   /topics/:topic_id/remove_connection(.:format) topics#remove_connection
#                     topic_create POST   /topics/:topic_id/create(.:format)            topics#create
#             topic_most_connected GET    /topics/:topic_id/most_connected(.:format)    topics#most_connected
#                    topic_related GET    /topics/:topic_id/related(.:format)           topics#related
#           topic_user_suggestions GET    /topics/:topic_id/user_suggestions(.:format)  topics#user_suggestions
#                   topic_add_user POST   /topics/:topic_id/add_user(.:format)          topics#add_user
#                topic_remove_user POST   /topics/:topic_id/remove_user(.:format)       topics#remove_user
#                      topic_users GET    /topics/:topic_id/users(.:format)             users#index
#                                  POST   /topics/:topic_id/users(.:format)             users#create
#                   new_topic_user GET    /topics/:topic_id/users/new(.:format)         users#new
#                  edit_topic_user GET    /topics/:topic_id/users/:id/edit(.:format)    users#edit
#                       topic_user GET    /topics/:topic_id/users/:id(.:format)         users#show
#                                  PATCH  /topics/:topic_id/users/:id(.:format)         users#update
#                                  PUT    /topics/:topic_id/users/:id(.:format)         users#update
#                                  DELETE /topics/:topic_id/users/:id(.:format)         users#destroy
#                           topics GET    /topics(.:format)                             topics#index
#                                  POST   /topics(.:format)                             topics#create
#                        new_topic GET    /topics/new(.:format)                         topics#new
#                       edit_topic GET    /topics/:id/edit(.:format)                    topics#edit
#                            topic GET    /topics/:id(.:format)                         topics#show
#                                  PATCH  /topics/:id(.:format)                         topics#update
#                                  PUT    /topics/:id(.:format)                         topics#update
#                                  DELETE /topics/:id(.:format)                         topics#destroy
#                   user_add_topic POST   /users/:user_id/add_topic(.:format)           users#add_topic
#                user_remove_topic POST   /users/:user_id/remove_topic(.:format)        users#remove_topic
#              user_most_connected GET    /users/:user_id/most_connected(.:format)      users#most_connected
#           user_topic_suggestions GET    /users/:user_id/topic_suggestions(.:format)   users#topic_suggestions
#                      user_topics GET    /users/:user_id/topics(.:format)              topics#index
#                                  POST   /users/:user_id/topics(.:format)              topics#create
#                   new_user_topic GET    /users/:user_id/topics/new(.:format)          topics#new
#                  edit_user_topic GET    /users/:user_id/topics/:id/edit(.:format)     topics#edit
#                       user_topic GET    /users/:user_id/topics/:id(.:format)          topics#show
#                                  PATCH  /users/:user_id/topics/:id(.:format)          topics#update
#                                  PUT    /users/:user_id/topics/:id(.:format)          topics#update
#                                  DELETE /users/:user_id/topics/:id(.:format)          topics#destroy
#                            users GET    /users(.:format)                              users#index
#                                  POST   /users(.:format)                              users#create
#                         new_user GET    /users/new(.:format)                          users#new
#                        edit_user GET    /users/:id/edit(.:format)                     users#edit
#                             user GET    /users/:id(.:format)                          users#show
#                                  PATCH  /users/:id(.:format)                          users#update
#                                  PUT    /users/:id(.:format)                          users#update
#                                  DELETE /users/:id(.:format)                          users#destroy
#

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
  # root 'index'

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
