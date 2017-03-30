class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example
    alias_action :create, :read, :update, to: :cru
    alias_action :create, :read, to: :cr
    alias_action :read, to: :r
    alias_action :create, to: :c
    alias_action :update, to: :u

    alias_action :create, :read, :update, :delete, to: :crud
       user ||= User.new # guest user (not logged in)
       if user.role == "root"
         can :manage, :all
       elsif user.role == "cajero"
         can :getById, Articulo
         can :showByCriteria, Articulo
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
       elsif user.role == "auxiliar"
         can :getById, Articulo
         can :showByCriteria, Articulo
         can :cru, Perfil
         can :crud, Cliente
         can :cru, DatosFiscalesCliente
         can :crud, Articulo
         can :crud, CatArticulo
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
       elsif user.role == "gerente"
         can :getById, Articulo
         can :showByCriteria, Articulo
         can :cru, Perfil
         can :cru, Cliente
         can :cru, DatosFiscalesCliente
         can :crud, Articulo
         can :crud, CatArticulo
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
