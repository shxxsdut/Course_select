Rails.application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root 'homes#index'

  resources :courses do
    member do
      get :select   #courseControll中的方法
      get :quit
      get :open
      get :close
      get :searchcourse
      get :coursedetails #显示课程详细信息
      get :credit #显示当前学分
    end

    collection do
      get :list
      get :coursetable #我的课表
    end
  end

  resources :grades, only: [:index, :update]

  resources :users #用户路由

  #Sessions资源使用具名路由 处理 GET POST DELETE请求  添加一个资源，获得会话标准REST动作
  get 'grades/degree' => 'grades#degree' #学位
  get 'grades/degree1' =>'grades#degree1'
  get 'grades/degree0' =>'grades#degree0'
  get 'grades/export' =>'grades#export'
  post 'grades/import' =>'grades#import'


  get 'sessions/login' => 'sessions#new'  #控制器+方法
  post 'sessions/login' => 'sessions#create'
  delete 'sessions/logout' => 'sessions#destroy'


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
