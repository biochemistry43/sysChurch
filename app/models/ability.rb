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
         can :getById, Articulo
         can :showByCriteria, Articulo
         can :r, Articulo
         can :r, MarcaProducto
         can :r, PresentacionProducto
         can :cru, Perfil
         can :cru, Cliente
         can :crud, DatosFiscalesCliente
         can :crud, Venta
         can :crud, ItemVenta
         can :crud, VentaFormaPago
         can :crud, VentaFormaPagoCampo
       elsif user.role == "administrador"
         can :getById, Articulo
         can :showByCriteria, Articulo
         can :cru, Perfil
         can :crud, Cliente
         can :cru, DatosFiscalesCliente
         can :crud, Articulo
         can :crud, CatArticulo
         can :crud, MarcaProducto
         can :crud, PresentacionProducto
         can :crud, Banco
         can :crud, CategoriaGasto
         can :crud, CategoriaPerdida
         can :crud, DatosFiscalesSucursal
         can :crud, DatosFiscalesNegocio
         can :crud, Gasto
         can :crud, ItemVenta
         can :cru, Negocio
         can :crud, Perdida
         can :cru, Perfil
         can :crud, Proveedor
         can :crud, Sucursal
         can :crud, TelefonoPersona
         can :crud, User
         can :crud, Venta
         can :crud, VentaFormaPago
         can :crud, VentaFormaPagoCampo
         can :cru, Compra
         can :cru, DetalleCompra
         can :cru, EntradaAlmacen
       elsif user.role == "subadministrador"
         can :getById, Articulo
         can :showByCriteria, Articulo
         can :cru, Perfil
         can :crud, Cliente
         can :cru, DatosFiscalesCliente
         can :crud, Articulo
         can :crud, CatArticulo
         can :crud, MarcaProducto
         can :crud, PresentacionProducto
         can :crud, Banco
         can :crud, CategoriaGasto
         can :crud, CategoriaPerdida
         can :crud, DatosFiscalesSucursal
         can :crud, DatosFiscalesNegocio
         can :crud, Gasto
         can :crud, ItemVenta
         can :cru, Negocio
         can :crud, Perdida
         can :cru, Perfil
         can :crud, Proveedor
         can :crud, Sucursal
         can :crud, TelefonoPersona
         can :crud, User
         can :crud, Venta
         can :crud, VentaFormaPago
         can :crud, VentaFormaPagoCampo
         can :cru, Compra
         can :cru, DetalleCompra
         can :cru, EntradaAlmacen
       elsif user.role == "gerente"
         can :getById, Articulo
         can :showByCriteria, Articulo
         can :cru, Perfil
         can :cru, Cliente
         can :cru, DatosFiscalesCliente
         can :crud, Articulo
         can :ru, CatArticulo
         can :crud, MarcaProducto
         can :crud, PresentacionProducto
         can :crud, Banco
         can :crud, CategoriaGasto
         can :crud, CategoriaPerdida
         can :crud, DatosFiscalesSucursal
         can :crud, DatosFiscalesNegocio
         can :crud, Gasto
         can :crud, ItemVenta
         can :cr, Negocio
         can :crud, Perdida
         can :cru, Perfil
         can :crud, Proveedor
         can :crud, Sucursal
         can :crud, TelefonoPersona
         can :crud, User
         can :crud, Venta
         can :crud, VentaFormaPago
         can :crud, VentaFormaPagoCampo
         can :cru, Compra
         can :cru, DetalleCompra
         can :cru, EntradaAlmacen
       elsif user.role == "auxiliar"
         can :getById, Articulo
         can :showByCriteria, Articulo
         can :cru, Perfil
         can :cru, Cliente
         can :ru, DatosFiscalesCliente
         can :r, Articulo
         can :r, CatArticulo
         can :r, Banco
         can :r, CategoriaGasto
         can :r, CategoriaPerdida
         can :r, DatosFiscalesSucursal
         can :r, DatosFiscalesNegocio
         can :cr, Gasto
         can :r, CategoriaGasto
         can :r, Negocio
         can :crud, Perdida
         can :cru, Perfil
         can :cru, Proveedor
         can :r, Sucursal
         can :ru, TelefonoPersona
         can :ru, User
         can :cr, Compra
         can :cr, DetalleCompra
         can :cr, EntradaAlmacen
       elsif user.role == "almacenista"
         can :cru, Perfil
         can :cru, Cliente
         can :cru, DatosFiscalesCliente
         can :cru, Articulo
         can :cru, CatArticulo
         can :crud, MarcaProducto
         can :crud, PresentacionProducto
         can :r, Negocio
         can :r, DatosFiscalesNegocio
         can :cru, Proveedor
         can :r, Sucursal
         can :r, DatosFiscalesSucursal
         can :crud, TelefonoPersona
         can :ru, User
         can :cr, Compra
         can :cr, DetalleCompra
         can :cr, EntradaAlmacen
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
