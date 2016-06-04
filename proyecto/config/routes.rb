Rails.application.routes.draw do

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/'
  get 'vista_bodega/generarVista'

  get 'vista_oc/generarVista'

  get 'vista_factura/generarVista'

  get 'welcome/index'
  
  get 'spree/orders/confirmarCompra/:boleta' => 'spree/orders#despachar'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  #get 'api/consultar'

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  #Documentacion API
  get '/documentacion', :to => redirect('/documentacion.html')
  # Example of regular route:
 
  get 'api/consultar/:sku' => 'api#consultarStock'

  get 'api/oc/recibir/:idoc' => 'api#recibirOC'

  get 'api/facturas/recibir/:idfactura' => 'api#recibirFactura'

  get 'api/pagos/recibir/:idtrx' => 'api#recibirPago'

  get 'api/despachos/recibir/:idfactura' => 'api#recibirDespacho'

  ## enviar informacion de nuestro servidor

  get 'api/ids/grupo' => 'api#enviarGrupo'

  get 'api/ids/banco' => 'api#enviarBanco'

  get 'api/ids/almacenId' => 'api#enviarAlmacen'


  #match "api/oc/recibir/", :to => "api#recibirOC", :via => :post


  #   get 'products/:id' => 'catalog#view'
  get 'logica/:idOrden' => 'logica#contestar'
  get 'actualizarInventario' => 'logica#actualizarInventario'
  get 'moverParaDespachar/:oc' => 'logica#moverA_Despacho'
  get 'producir/:sku/:trx/:cantidad' => 'logica#producir'
  get 'revisarStock' => 'logica#revisarStock'
  get 'revisarRecepcion' => 'logica#revisarRecepcion'
  get 'despachar/:sku/:cantidad/:cliente' => 'logica#despachar'
  get 'llenarOrden' => 'logica#llenarOrden'
  get 'contestarOrdenServidor' => 'logica#contestarOrdenServidor'
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
