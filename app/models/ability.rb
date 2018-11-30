class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example
    alias_action :create, :read, :update, to: :cru
    alias_action :create, :read, to: :cr
    alias_action :read, to: :r
    alias_action :create, to: :c
    alias_action :update, to: :u
    alias_action :read, :update, to: :ru

    alias_action :create, :read, :update, :destroy, to: :crud
       user ||= User.new # guest user (not logged in)
       if user.role == "root"
         can :manage, :all
       elsif user.role == "cajero"

         can :ru, Articulo
         can :getById, Articulo
         can :showByCriteriaForPos, Articulo
         can :showByCriteria, Articulo
         can :ru, CajaSucursal
         can :cru, CampoFormaPago
         can :ru, CampoFormaPagoItem
         can :ru, CatArticulo
         can :ru, FormaPago
         can :crud, ItemVenta
         can :r, MarcaProducto
         can :cru, MovimientoCajaSucursal
         can :cru, Perfil
         can :r, PresentacionProducto
         can :ru, Proveedor
         can :crud, RetiroCajaVenta
         can :crud, TelefonoPersona
         can :ru, User
         can :crud, Venta
         can :buscarUltimoFolio, Venta
         can :consulta_ventas, Venta
         can :consulta_avanzada, Venta
         can :crud, VentaFormaPago
         can :crud, VentaFormaPagoCampo

         #MÓDULO DE FACTURACIÓN
         can :cru, Cliente
         can :cru, DatosFiscalesCliente
         can :r, Negocio #No, no, nou, actulizar no!.
         can :r, DatosFiscalesNegocio
         can :r, Sucursal
         can :r, DatosFiscalesSucursal

         can :index_facturas_ventas, Factura
         can :mostrar_detalles, Factura
         can :buscar_venta, Factura
         can :consulta_por_fecha, Factura
         can :consulta_por_folio, Factura
         can :consulta_por_cliente, Factura
         can :consulta_avanzada, Factura
         can :facturar_venta, Factura
         can :visualizar_pdf, Factura
         can :enviar_email, Factura
         can :descargar_cfdis, Factura

         can :index_facturas_globales, Factura

         
       elsif user.role == "administrador"

         can :crud, Articulo
         can :getById, Articulo
         can :showByCriteria, Articulo
         can :showByCriteriaForPos, Articulo
         can :solo_sucursal, Articulo
         can :baja_existencia, Articulo
         can :consulta_avanzada, Articulo
         can :crud, Banco
         can :crud, CajaChica
         can :crud, CajaSucursal
         can :ru, CampoFormaPago
         can :ru, CampoFormaPagoItem
         can :crud, CatArticulo
         can :crud, CatCompraCancelada
         can :crud, CatVentaCancelada
         can :crud, CategoriaGasto
         can :crud, CategoriaPerdida
         
         can :crud, Compra 
         can :consulta_compra_factura, Compra
         can :consulta_compras, Compra
         can :consulta_avanzada, Compra
         can :solo_sucursal, Compra
         can :actualizar, Compra
         can :crud, CompraArticulosDevuelto
         can :crud, CompraCancelada

         can :crud, DetalleCompra
         can :crud, EntradaAlmacen
         can :ru, FormaPago
         can :crud, Gasto
         can :crud, GastoGeneral
         can :crud, HistorialEdicionesCompra
         can :crud, ItemVenta
         can :crud, MarcaProducto
         can :crud, MovimientoCajaSucursal
         
         can :updateDatosFiscales, Negocio
         can :crud, PagoDevolucion
         can :crud, PagoPendiente
         can :crud, PagoProveedor
         can :cru, Perfil
         can :crud, PresentacionProducto
         can :crud, Proveedor
         can :crud, RetiroCajaVenta
         
         can :crud, TelefonoPersona
         can :ru, User
         can :crud, Venta
         can :buscarUltimoFolio, Venta
         can :consulta_ventas, Venta
         can :consulta_avanzada, Venta
         can :solo_sucursal, Venta
         can :crud, VentaCancelada
         can :consulta_por_fecha, VentaCancelada
         can :consulta_por_producto, VentaCancelada
         can :consulta_avanzada, VentaCancelada
         can :devolcion, VentaCancelada
         can :hacerDevolucion, VentaCancelada
         can :consulta_por_fecha, DevolucionesController
         can :consulta_por_producto, DevolucionesController
         can :consulta_avanzada, DevolucionesController
         can :devolcion, DevolucionesController
         can :hacerDevolucion, DevolucionesController
         can :crud, VentaFormaPago
         can :crud, VentaFormaPagoCampo


         #MÓDULO DE FACTURACIÓN
         can :crud, Cliente
         can :crud, DatosFiscalesCliente
         can :cru, Negocio #Puede crear un negocio?* En un futuro si.
         can :cru, DatosFiscalesNegocio
         can :cru, Sucursal
         can :cru, DatosFiscalesSucursal
         can :crud, Impuesto
         can :update, PlantillasEmail
         can :update, ConfigComprobante

         can :index_facturas_ventas, Factura
         can :mostrar_detalles, Factura
         can :buscar_venta, Factura
         can :consulta_por_fecha, Factura
         can :consulta_por_folio, Factura
         can :consulta_por_cliente, Factura
         can :consulta_avanzada, Factura
         can :facturar_venta, Factura
         can :visualizar_pdf, Factura
         can :enviar_email, Factura
         can :descargar_cfdis, Factura
         can :cancelar_factura, Factura


         can :index_facturas_globales, Factura


         

       elsif user.role == "subadministrador"

         can :crud, Articulo
         can :getById, Articulo
         can :showByCriteria, Articulo
         can :showByCriteriaForPos, Articulo
         can :solo_sucursal, Articulo
         can :baja_existencia, Articulo
         can :consulta_avanzada, Articulo
         can :crud, Banco
         can :crud, CajaChica
         can :crud, CajaSucursal
         can :ru, CampoFormaPago
         can :ru, CampoFormaPagoItem
         can :crud, CatArticulo
         can :crud, CatCompraCancelada
         can :crud, CatVentaCancelada
         can :crud, CategoriaGasto
         can :crud, CategoriaPerdida
         can :crud, Cliente
         can :crud, Compra 
         can :consulta_compra_factura, Compra
         can :consulta_compras, Compra
         can :consulta_avanzada, Compra
         can :solo_sucursal, Compra
         can :actualizar, Compra
         can :crud, CompraArticulosDevuelto
         can :crud, CompraCancelada
         can :crud, DatosFiscalesCliente
         can :ru, DatosFiscalesNegocio
         can :crud, DatosFiscalesSucursal
         can :crud, DetalleCompra
         can :crud, EntradaAlmacen
         can :ru, FormaPago
         can :crud, Gasto
         can :crud, GastoGeneral
         can :crud, HistorialEdicionesCompra
         can :crud, ItemVenta
         can :crud, MarcaProducto
         can :crud, MovimientoCajaSucursal
         can :cru, Negocio
         can :updateDatosFiscales, Negocio
         can :crud, PagoDevolucion
         can :crud, PagoPendiente
         can :crud, PagoProveedor
         can :cru, Perfil
         can :crud, PresentacionProducto
         can :crud, Proveedor
         can :crud, RetiroCajaVenta
         can :cru, Sucursal
         can :crud, TelefonoPersona
         can :ru, User
         can :crud, Venta
         can :buscarUltimoFolio, Venta
         can :consulta_ventas, Venta
         can :consulta_avanzada, Venta
         can :solo_sucursal, Venta
         can :crud, VentaCancelada
         can :consulta_por_fecha, VentaCancelada
         can :consulta_por_producto, VentaCancelada
         can :consulta_avanzada, VentaCancelada
         can :devolcion, VentaCancelada
         can :hacerDevolucion, VentaCancelada
         can :consulta_por_fecha, DevolucionesController
         can :consulta_por_producto, DevolucionesController
         can :consulta_avanzada, DevolucionesController
         can :devolcion, DevolucionesController
         can :hacerDevolucion, DevolucionesController
         can :crud, VentaFormaPago
         can :crud, VentaFormaPagoCampo

         #MÓDULO DE FACTURACIÓN
         can :crud, Cliente
         can :crud, DatosFiscalesCliente
         can :cru, Negocio #Puede crear un negocio?* En un futuro si.
         can :cru, DatosFiscalesNegocio
         can :cru, Sucursal
         can :cru, DatosFiscalesSucursal
         can :crud, Impuesto
         can :update, PlantillasEmail
         can :update, ConfigComprobante

         can :index_facturas_ventas, Factura
         can :mostrar_detalles, Factura
         can :buscar_venta, Factura
         can :consulta_por_fecha, Factura
         can :consulta_por_folio, Factura
         can :consulta_por_cliente, Factura
         can :consulta_avanzada, Factura
         can :facturar_venta, Factura
         can :visualizar_pdf, Factura
         can :enviar_email, Factura
         can :descargar_cfdis, Factura
         can :cancelar_factura, Factura


         can :index_facturas_globales, Factura


       elsif user.role == "gerente"

         can :crud, Articulo
         can :getById, Articulo
         can :showByCriteria, Articulo
         can :showByCriteriaForPos, Articulo
         can :solo_sucursal, Articulo
         can :baja_existencia, Articulo
         can :consulta_avanzada, Articulo
         can :cru, Banco
         can :crud, CajaChica
         can :crud, CajaSucursal
         can :ru, CampoFormaPago
         can :ru, CampoFormaPagoItem
         can :ru, CatArticulo
         can :ru, CatCompraCancelada
         can :ru, CatVentaCancelada
         can :ru, CategoriaGasto
         can :ru, CategoriaPerdida
         can :crud, Cliente
         can :crud, Compra
         can :consulta_compra_factura, Compra
         can :consulta_compras, Compra
         can :consulta_avanzada, Compra
         can :actualizar, Compra
         can :crud, CompraArticulosDevuelto
         can :crud, CompraCancelada
         can :crud, DatosFiscalesCliente
         can :read, DatosFiscalesNegocio
         can :crud, DatosFiscalesSucursal
         can :crud, DetalleCompra
         can :crud, EntradaAlmacen
         can :ru, FormaPago
         can :crud, Gasto
         can :crud, GastoGeneral
         can :cru, HistorialEdicionesCompra
         can :crud, ItemVenta
         can :crud, MarcaProducto
         can :crud, MovimientoCajaSucursal
         can :read, Negocio
         can :crud, PagoDevolucion
         can :crud, PagoPendiente
         can :crud, PagoProveedor
         can :cru, Perfil
         can :crud, PresentacionProducto
         can :crud, Proveedor
         can :crud, RetiroCajaVenta
         can :ru, Sucursal
         can :crud, TelefonoPersona
         can :ru, user
         can :crud, Venta
         can :buscarUltimoFolio, Venta
         can :consulta_ventas, Venta
         can :consulta_avanzada, Venta
         can :crud, VentaCancelada
         can :consulta_por_fecha, VentaCancelada
         can :consulta_por_producto, VentaCancelada
         can :consulta_avanzada, VentaCancelada
         can :devolucion, VentaCancelada
         can :hacerDevolucion, VentaCancelada
         can :consulta_por_fecha, DevolucionesController
         can :consulta_por_producto, DevolucionesController
         can :consulta_avanzada, DevolucionesController
         can :devolucion, DevolucionesController
         can :hacerDevolucion, DevolucionesController

         can :crud, VentaFormaPago
         can :crud, VentaFormaPagoCampo


       elsif user.role == "auxiliar"

         can :read, Articulo
         can :getById, Articulo
         can :showByCriteria, Articulo
         can :solo_sucursal, Articulo
         can :baja_existencia, Articulo
         can :consulta_avanzada, Articulo
         can :read, Banco
         can :read, CajaChica
         can :read, CajaSucursal
         can :read, CampoFormaPago
         can :read, CampoFormaPagoItem
         can :read, CatArticulo
         can :read, CatCompraCancelada
         can :read, CatVentaCancelada
         can :read, CategoriaGasto
         can :read, CategoriaPerdida
         can :crud, Cliente
         can :read, Compra
         can :consulta_compra_factura, Compra
         can :consulta_compras, Compra
         can :consulta_avanzada, Compra
         can :actualizar, Compra
         can :read, CompraArticulosDevuelto
         can :read, CompraCancelada
         can :read, DatosFiscalesCliente
         can :read, DatosFiscalesNegocio
         can :read, DatosFiscalesSucursal
         can :read, EntradaAlmacen
         can :read, FormaPago
         can :crud, Gasto
         can :crud, GastoGeneral
         can :read, ItemVenta
         can :crud, MarcaProducto
         can :crud, MovimientoCajaSucursal
         can :read, Negocio
         can :cru, Perfil
         can :crud, PresentacionProducto
         can :crud, Proveedor
         can :crud, RetiroCajaVenta
         can :read, Sucursal
         can :crud, TelefonoPersona
         can :ru, User
         can :read, Venta
         can :buscarUltimoFolio, Venta
         can :consulta_ventas, Venta
         can :consulta_avanzada, Venta
         can :ru, VentaCancelada
         can :consulta_por_fecha, VentaCancelada
         can :consulta_por_producto, VentaCancelada
         can :consulta_avanzada, VentaCancelada
         can :devolucion, VentaCancelada
         can :consulta_por_fecha, DevolucionesController
         can :consulta_por_producto, DevolucionesController
         can :consulta_avanzada, DevolucionesController
         can :devolucion, DevolucionesController
         can :read, VentaFormaPago
         can :read, VentaFormaPagoCampo


       elsif user.role == "almacenista"

         can :crud, Articulo
         can :getById, Articulo
         can :showByCriteria, Articulo
         can :solo_sucursal, Articulo
         can :baja_existencia, Articulo
         can :consulta_avanzada, Articulo
         can :read, CatArticulo
         can :read, CatCompraCancelada
         can :read, CatVentaCancelada
         can :read, CategoriaGasto
         can :read, CategoriaPerdida
         can :read, Cliente
         can :crud, Compra
         can :consulta_compra_factura, Compra
         can :consulta_compras, Compra
         can :consulta_avanzada, Compra
         can :actualizar, Compra
         can :crud, CompraArticulosDevuelto
         can :crud, CompraCancelada
         can :read, DatosFiscalesCliente
         can :read, DatosFiscalesNegocio
         can :read, DatosFiscalesSucursal
         can :crud, DetalleCompra
         can :crud, EntradaAlmacen
         can :ru, FormaPago
         can :crud, Gasto
         can :crud, GastoGeneral
         can :crud, HistorialEdicionesCompra
         can :crud, MarcaProducto
         can :read, Negocio
         can :cru, Perfil
         can :crud, PresentacionProducto
         can :crud, Proveedor
         can :read, Sucursal
         can :crud, TelefonoPersona
         can :ru, User
         can :buscarUltimoFolio, Venta

         #MÓDULO DE FACTURACIÓN

         
       end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
