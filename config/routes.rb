Rails.application.routes.draw do

  devise_for :staffs,controllers:{
  	sessions: 'staffs/sessions'
  }
  devise_for :owners,controllers:{
  	sessions: 'owners/sessions',
    registrations: 'owners/registrations'
  }

  root :to => "tops#about"

  concern :today_girl do
    resources :today_girls, only:[:edit,:update]
  end

  concern :today do
	  resource :todays, only:[:new,:create,:destroy],concerns: [:today_girl]
	  get 'todays/thanks' => "todays#thanks"
    get 'todays/index' => "todays#index"
    get 'todays/confirm' => "todays#confirm"
  end

  concern :payment do
	  resources :payments, only:[:index,:new,:create]
  end

  concern :today_grade do
	  resources :today_grades, only:[:show],concerns: :payment
	  get 'todays/finish' => "todays_grades#finish"
	  get 'todays/confirm' => "todays_grades#confirm"
  end

  concern :order do
	  resources :orders, only:[:new,:create]
  end

  concern :accounting do
    resources :accountings, only:[:new,:create]
    get 'accountings/edit' => "accountings#edit",as: 'edit_accounting'
    patch 'accountings/update' => "accountings#update",as: 'accountings_update'
  end

  concern :table_girl do
    resources :table_girls, only:[:update]
  end

  concern :table do
	  resources :tables, only:[:new,:create,:show,:edit,:update],concerns: [:order,:accounting,:table_girl]
    get 'tables/:id/occurrence' =>"tables#occurrence", as:'table_occurrence'
    post 'tables/:id/occurrence' =>"tables#occurrence_create", as:'table_occurrence_create'
	  get 'tables/:id/add' => "tables#add"
	  patch 'tables/:id/add' => "tables#adding"
	  get 'tables/:id/extension' => "tables#extension", as:'table_extension'
	  patch 'tables/:id/exsention' => "tables#extensioning",as:'table_extensioning'
	  get 'tables/:id/special' => "tables#special"
	  patch 'tables/:id/special' => "tables#specialing"
    post 'tables/:id/card' => "tables#card", as:'table_card'
    get 'tables/:id/and_card' => "tables#and_card", as:'table_and_card'
    patch 'tables/:id/and_carding' => "tables#and_carding", as:'table_and_carding'
    post 'tables/:id/cash' => "tables#cash", as:'table_cash'
    post 'tables/:id/table_girl/:table_girl_id' => "table#hall",as:'table_hall'
  end

  concern :mounth_grade do
  	resources :mounth_grades, only:[:index], concerns: :today_grade
  end

  concern :staff do
  	resources :staffs, only:[:index,:create,:edit,:update]
  end

  concern :product do
  	resources :products, only:[:index,:new,:create,:destroy]
  end

  concern :girl do
  	resources :girls, only:[:index,:create,:edit,:show,:update,:destroy]
  end

  resources :shops, only:[:index,:new,:create,:edit,:update,:destroy],concerns: [:girl, :product, :staff, :today, :mounth_grade, :table]
  get 'shops/add' => "shops#add", as: 'add_shop'
  post 'shops/add' => "shops#adding", as:'adding_shop'
  get 'shop/:id/top' => "shops#top", as: 'shop_top'
  get 'shop/:id/roll' => "shops#roll", as: 'shop_roll'
  patch 'shop/:id/rolling' => "shops#rolling",as: 'shop_rolling'
  get 'shop/:id/detial' => "shops#detial", as: 'shop_detial'
  patch 'shop/:id/detial' => "shops#setting", as:'shop_detial_set'
  delete 'shop/;id/release' => "shops#release", as:'shop_release'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
