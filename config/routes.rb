Rails.application.routes.draw do

  #resources :plantillas_emails
  post 'plantillas_emails/update'
  
  post 'plantillas_emails/mostrar_plantilla'
  get 'plantillas_emails/mostrar_plantilla'

  resources :config_comprobantes
  resources :impuestos
  #resources :nota_creditos
  get 'nota_creditos/index'
  get 'nota_creditos/show'
  get 'nota_creditos/imprimirpdf'
  post 'nota_creditos/consulta_por_fecha'
  post 'nota_creditos/consulta_por_folio'
  post 'nota_creditos/consulta_por_cliente'
  post 'nota_creditos/consulta_por_cfdi_relacionado'
  post 'nota_creditos/consulta_avanzada'
  get 'nota_creditos/descargar_nota_credito'
  get 'nota_creditos/mostrar_email_nota_credito'
  post 'nota_creditos/enviar_nota_credito'
  get 'nota_creditos/mostrar_email_cancelacion_nc'
  post 'nota_creditos/cancelar_nota_credito'

  resources :unidad_medidas
  resources :uso_cfdis
  resources :clave_prod_servs
  resources :metodo_pagos
  #resources :factura_recurrentes
  get 'factura_recurrentes/index'
  get 'factura_recurrentes/show'
  post 'factura_recurrentes/consulta_facturas'
  post 'factura_recurrentes/consulta_avanzada'
  post 'factura_recurrentes/facturaRecurrentes'
  get 'factura_recurrentes/facturaRecurrentes'

  #resources :facturas
  get 'facturas/index'
  get 'facturas/index_facturas_globales'
  get 'facturas/show'
  get 'facturas/new'
  get 'facturas/create'
  get 'facturas/edit'
  get 'facturas/update'
  get 'facturas/destroy'

  post 'facturas/buscarVentaFacturar'
  get 'facturas/buscarVentaFacturar'

  post 'facturas/consulta_facturas'
  post 'facturas/consulta_por_folio'
  post 'facturas/consulta_por_cliente'
  post 'facturas/consulta_avanzada'
  #get 'facturas/mostrarDetallesVenta'
  post 'facturas/facturarVenta'
  get 'facturas/readpdf'
  get 'facturas/enviar_email'
  post 'facturas/enviar_email_post'
  get 'facturas/descargar_cfdis'
  get 'facturas/cancelar_cfdi'
  get 'facturas/factura_global_publico_gral'
  post 'facturas/factura_global_publico_gral'

  get 'facturas/cancelaFacturaVenta'
  post 'facturas/cancelaFacturaVenta2'
  #resources :facturas

  get 'facturas/generarFacturaGlobal'
  post 'facturas/mostrarVentas_FacturaGlobal'



  get 'corte_cajas/show'

  post 'corte_cajas/show'

  get 'reporte_gastos/reporte_gastos'

  get 'reporte_ventas/reporte_ventas'

  post 'reporte_gastos/reporte_gastos'

  post 'reporte_ventas/reporte_ventas'

  resources :gasto_generals
  resources :pago_pendientes
  get 'pago_pendientes/index'
  get 'pago_pendientes/show'
  get 'pago_pendientes/edit'
  get 'pago_pendientes/update'
  get 'pago_pendientes/destroy'

  resources 'caja_chicas'
  get 'caja_chicas/index'
  get 'caja_chicas/show'
  get 'caja_chicas/create'
  get 'caja_chicas/edit'
  get 'caja_chicas/update'
  get 'caja_chicas/destroy'
  get 'caja_chicas/new'
  post 'caja_chicas/movimientos_sucursal'

  resources :caja_sucursals
  resources :cat_compra_canceladas

  get 'devoluciones/index'
  get 'devoluciones/show'
  get 'devoluciones/devolucion'
  post 'devoluciones/devolucion'
  post 'devoluciones/hacerDevolucion'
  get 'devoluciones/new'
  post 'devoluciones/consulta_por_fecha'
  post 'devoluciones/consulta_por_producto'
  post 'devoluciones/consulta_avanzada'

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
  post 'compras/consulta_compra_factura'
  post 'compras/consulta_avanzada'
  post 'compras/solo_sucursal'
  get 'compras/buscarUltimoFolio'
  get 'compras/actualizar'
  post 'compras/actualizar'

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
  get 'ventas/buscarUltimoFolio'

  devise_for :users, controllers: { sessions: "users/sessions" }
  resources :bancos
  resources :proveedores
  get 'inventarios/index'

  resources :articulos
  get 'articulos/showByCriteria'
  get 'articulos/showByCriteriaForPos'
  get 'articulos/getById'
  post 'articulos/consulta_avanzada'
  post 'articulos/solo_sucursal'
  post 'articulos/baja_existencia'
  get 'plainpage/index'


  resources :gastos
  resources :gasto_corrientes
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
  get 'articulos/showByCriteriaForPos/:criteria' => 'articulos#showByCriteriaForPos'
  get 'articulos/getById/:criteria' => 'articulos#getById'
  get 'ventas/buscarUltimoFolio/:criteria' => 'ventas#buscarUltimoFolio'
  get 'inventarios/showByCriteria/:criteria' => 'inventarios#showByCriteria'
  get 'ventas/venta_del_dia' => 'ventas#venta_del_dia'
  post 'ventas/venta_del_dia' => 'ventas#venta_del_dia'
  post 'punto_venta/obtenerCamposFormaPago/:formaPago' => 'punto_venta#obtenerCamposFormaPago'
  post 'punto_venta/realizarVenta/:venta' => 'punto_venta#realizarVenta'
  get 'punto_venta/index/:venta' => 'punto_venta#index'
  get 'compras/actualizar/:id' => 'compras#actualizar'
  post 'compras/actualizar/:id' => 'compras#actualizar'
  put 'compras/actualizar/:id' => 'compras#actualizar'
  patch 'compras/actualizar/:id' => 'compras#actualizar'
  get 'gastos_generales' => 'gasto_corrientes#index'


  post 'gasto_generals/solo_sucursal'
  post 'gasto_generals/consulta_avanzada'
  post 'gasto_generals/consulta_por_fechas'


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
