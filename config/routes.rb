Rails.application.routes.draw do

  get 'devoluciones/index'

  get 'devoluciones/show'

  get 'devoluciones/devolucion'

  post 'devoluciones/devolucion'

  post 'devoluciones/hacerDevolucion'

  resources :cat_venta_canceladas
  resources :compras
  get 'compras/index'
  get 'compras/new'
  get 'compras/show'
  get 'compras/create'
  get 'compras/edit'
  get 'compras/update'
  get 'compras/destroy'
  post 'compras/consulta_compras'

  resources :presentacion_productos
  resources :marca_productos
  
  resources :empleados
  get 'empleados/index'
  get 'empleados/show'
  get 'empleados/new'
  get 'empleados/edit'
  get 'empleados/create'
  get 'empleados/update'
  get 'empleados/destroy'

  get 'datos_fiscales_negocios/index'
  get 'datos_fiscales_negocios/show'
  get 'datos_fiscales_negocios/new'
  get 'datos_fiscales_negocios/create'
  get 'datos_fiscales_negocios/update'
  get 'datos_fiscales_negocios/destroy'

  resources :clientes  
  get 'clientes/index'
  get 'clientes/show'
  get 'clientes/new'
  get 'clientes/destroy'
  get 'clientes/update'
  get 'clientes/create'
  get 'perfil/index'

  resources :negocios
  resources :datos_fiscales_negocios

  

  resources :sucursals
  resources :ventas
  get 'ventas/venta_del_dia'
  post 'ventas/venta_del_dia'
  post 'ventas/consulta_ventas'
  post 'ventas/consulta_avanzada'
  post 'ventas/solo_sucursal'

  devise_for :users, controllers: { sessions: "users/sessions" }
  resources :bancos
  resources :proveedores
  get 'inventarios/index'
  
  resources :articulos
  get 'articulos/showByCriteria'
  get 'articulos/getById'
  get 'plainpage/index'


  resources :gastos
  resources :categoria_gastos
  resources :cat_articulos
  resources :usuarios
  resources :tipo_usuarios
  resources :punto_venta
  post 'punto_venta/realizarVenta'
  post 'punto_venta/obtenerCamposFormaPago'

  resources :inventarios
  #resources :punto_venta
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
   
  # You can have the root of your site routed with "root"
  #root 'devise/registrations#new'
  
  get 'inventarios/showByCriteria'
  get 'articulos/showByCriteria/:criteria' => 'articulos#showByCriteria'
  get 'articulos/getById/:criteria' => 'articulos#getById'
  get 'inventarios/showByCriteria/:criteria' => 'inventarios#showByCriteria'
  get 'ventas/venta_del_dia' => 'ventas#venta_del_dia'
  post 'punto_venta/obtenerCamposFormaPago/:formaPago' => 'punto_venta#obtenerCamposFormaPago'
  post 'punto_venta/realizarVenta/:venta' => 'punto_venta#realizarVenta'
  
  
  root :to=> 'plainpage#index'
  devise_scope :user do 
    #devise_for :users
    get "/login" => "devise/sessions#new"
    delete "/logout" => "devise/sessions#destroy"
    get "/" => "users/sessions#new"
  end

  resources :users do
    resources :ventas
  end

  resources :perfils
  #devise_scope :user do
  #  root :to => 'devise/sessions#new'
  #end

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
