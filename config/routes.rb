##
# This is the routing maps for the site. Any request goes through this document and is parsed to a controller. 
# The format is:
#   requestmethod "/textpath/:parameter" => "controllername#controllermethod", additional_parameter: value
#

Rails.application.routes.draw do
  resources :seo_files

  resources :page_identifiers

  resources :seo_validations

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # Default Object Routes
  resources :action_logs
  
  resources :brands

  resources :brandurldata

  resources :browsertypes

  resources :error_messages

  resources :offer_data_details

  resources :workers

  resources :locators
  
  resources :error_codes

  resources :pixel_tests


  # Active Directory Login
  resources :sessions

  match "/signout" => "sessions#destroy", via: :all
  match "/adauth" => "sessions#create", via: :all

  
  # pause/resume test suite functionality
  post "/:type/:id/pause" => "testsuites#pause"
  post "/:type/:id/resume" => "testsuites#resume"

  
  # locator import form routes
  post 'locators/previewimport' => 'locators#previewimport'
  post 'locators/import' => 'locators#import'

  
  # pixel test addition routes
  post 'pixel_tests/:pixelsuite/duplicate' => 'pixel_tests#duplicate'
  post 'pixels/previewimport' => 'pixel_tests#previewimport'
  post 'pixel_tests/previewimport' => 'pixel_tests#previewimport'
  post 'pixels/import' => 'pixel_tests#import'

  
  # test configuration routes for vanity and UCI
  get 'test_config/vanity' => 'pixel_tests#index', suitetype: 'Vanity'
  get 'test_config/uci' => 'pixel_tests#index', suitetype: 'UCI'
  get 'test_config/seo' => 'pixel_tests#index', suitetype: 'seo'

  
  # new test run object routes - used for Pixel, Vanity, and UCI tests
  get 'test_run/new' => 'test_run#new'
  get 'test_run/:id' => 'test_run#show'
  patch 'test_run/:id' => 'test_run#updatenotes'
  post 'test_run/create/pixel' => 'test_run#create_run'
  post 'test_run/create/vanity' => 'test_run#create_run', suitetype: 'Vanity'
  post 'test_run/create/uci' => 'test_run#create_run', suitetype: 'UCI'
  post 'test_run/create/seo' => 'test_run#create_run', suitetype: 'seo'

  
  # cart details management
  get 'cartdetails' => 'cartdetails#index'
  post 'cartdetails/:offercode' => 'cartdetails#create'
  get 'cartdetails/new' => 'cartdetails#new'
  get 'cartdetails/edit' => 'cartdetails#edit'
  patch 'cartdetails/:offercode' => 'cartdetails#update'
  delete 'cartdetails/:offercode' => 'cartdetails#delete'

  # ------ API Methods -----

  
  # Pixels
  get 'api/pixels/:suite/url' => 'pixel_tests#url'
  post 'api/pixels/:suite/url' => 'pixel_tests#addurl'
  get 'api/pixels/:suite/url/:urlid/pixels' => 'pixel_tests#pixeldata'
  post 'api/pixels/:suite/url/:urlid/pixels' => 'pixel_tests#addpixeldata'
  
  
  # test urls
  get 'api/testurls/suite/:id' => 'api_test_url#suite'
  get 'api/testurls' => 'api_test_url#index'
  post 'api/testurls' => 'api_test_url#create'
  delete 'api/testurls/:id' => 'api_test_url#delete'
  post 'api/testurls/:id' => 'api_test_url#update'

  
  # individual pixel data (keyed by url/pixelname combination)
  get 'api/pixeldata' => 'pixel_data#index'
  get 'api/pixeldata/url/:urlid' => 'pixel_data#for_url'
  post 'api/pixeldata' => 'pixel_data#create'
  delete 'api/pixeldata/:id' => 'pixel_data#delete'
  delete 'api/pixeldata/url/:urlid/:pixelname' => 'pixel_data#delete_by_url'
  post 'api/pixeldata/:id' => 'pixel_data#update'


  # testrun routes
  get 'testruns/index' => 'testruns#index'
  get 'testruns/show/:id' => 'testruns#show'
  get 'testruns/new' => 'testruns#new'
  patch 'testruns/:id' => 'testruns#updatenotes'

  # Pixel Testing Test Routes
  get 'testsuites/pixels' => 'testsuites#index', suitetype: 'pixels'
  get 'testsuites/vanity' => 'testsuites#index', suitetype: 'Vanity'
  get 'testsuites/uci' => 'testsuites#index', suitetype: 'UCI'
  get 'testsuites/seo' => 'testsuites#index', suitetype: 'seo'
  get 'testsuites/pixels/new' => 'testsuites#new_pixel', suitetype: 'pixels'
  post 'testsuites/pixels' => 'testsuites#create', suitetype: 'pixels'

  # Pixel Testing Data Routes

  get 'pixels' => 'testsuites#index', suitetype: 'pixels'

  get 'pixels/new' => 'pixel_tests#new'
  get 'vanity/new' => 'pixel_tests#new', suitetype: 'Vanity'
  get 'seo/new' => 'pixel_tests#new', suitetype: 'seo'
  get 'uci/new' => 'pixel_tests#new', suitetype: 'UCI'
  get 'pixels/:suite' => 'pixel_tests#show'
  post 'pixels/' => 'pixel_tests#create'
  get 'pixels/:suite/edit' => 'pixel_tests#edit'
  
  # Scheduling routes

  get 'schedule/new' => 'schedule#new'
  patch 'schedule/:id' => 'schedule#update'
  get 'schedule/:id' => 'schedule#show'
  get 'schedule/edit/:id' => 'schedule#edit'
  delete 'schedule/:id' => 'schedule#delete'
  post 'schedule/disable/:id' => 'schedule#disable'
  post 'schedule/enable/:id' => 'schedule#enable'
  post 'schedule/run/:id' => 'schedule#run'
  get 'schedule/' => 'schedule#index'


  # Test Suite overview pages
  get 'buyflow' => 'testsuites#index', suitetype: 'Buyflow'
  get 'vanity' => 'testsuites#index', suitetype: 'Vanity'
  get 'uci' => 'testsuites#index', suitetype: 'UCI'
  get 'offercode' => 'testsuites#index', suitetype: 'Offercode'
  get 'seo' => 'testsuites#index', suitetype: 'seo'

  #get 'testruns/:id/create' => 'testruns#create', type: 'Offercode'
  
  # additional campaign routes
  get 'campaigns/:id/duplicate' => 'campaigns#duplicate'
  get 'campaigns/bybrand/:brand/:environment(.:format)' => 'campaigns#environment'
  get 'campaigns/bybrand/:brand(.:format)' => 'campaigns#brand'


  # new test run creation routes
  get '/testsuites/new/offercode' => 'testruns#new', type: 'offercode'
  get '/testsuites/new/buyflow' => 'testruns#new', type: 'buyflow'
  post '/testsuites/offercode/create' => 'testsuites#offercode_create', type: 'offercode'
  post '/testsuites/buyflow/create' => 'testsuites#buyflow_create', type: 'buyflow'

  # legacy offerdata routes, most unused at this point
  post '/offerdata/deactivate/:brand/:campaign/:env/:platform' => 'offerdata#deactivate'
  post '/offerdata/update/' => 'offerdata#update'
  post '/offerdata/previewimport/' => 'offerdata#preview'
  get '/offerdata/import/' => 'offerdata#import'

  # Non user directed view on test runs. Harmless and left in if anyone wants to link to it in the future or finds a valueable use for it. 
  get '/queue' => 'testruns#simple_queue', suitetype: 'Queue'

  # User Authentication Routes - Legacy routes forwarded to new ActiveDirectory session functionality
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'
  get '/login' => 'sessions#new'

  # Test Suite Deletion Routes
  delete '/buyflow/:id/delete' => 'testsuites#destroy', type: 'buyflow'
  delete '/offercode/:id/delete' => 'testsuites#destroy', type: 'offercode'
  delete '/pixels/:id/delete' => 'testsuites#destroy', type: 'pixels'
  delete '/vanity/:id/delete' => 'testsuites#destroy', type: 'vanity'
  delete '/uci/:id/delete' => 'testsuites#destroy', type: 'uci'
  delete '/seo/:id/delete' => 'testsuites#destroy', type: 'seo'

  # Test Suite download route for export excel sheet
  get '/download/:id' => 'testsuites#download'

  # Admin Dashboard
  get '/admin' => 'dashboard#admin_dash'
  post '/admin' => 'dashboard#admin_dash'

  # Scheduling overview
  get 'schedule' => 'schedule#index'

  # testrun default routes
  resources :testruns, type: ''

  # test suite default routes
  resources :testsuites
  
  # offerdata default routes - Note: This is not used much anymore with the addition of the campaigns - offerdata link
  resources :offerdata

  # campaigns default routes
  resources :campaigns
  # This is the route
  root 'dashboard#index'




## EXAMPLES FOR DIFFERENT ROUTES
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
