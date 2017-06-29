class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :tipo_usuario
  has_one :perfil
  has_many :ventas
  has_many :compras
  #El usuario que cancela debe tener los privilegios para cancelar una venta
  has_many :venta_canceladas
  #El usuario que cancela debe tener los privilegios para cancelar una compra
  has_many :compra_canceladas
  #El usuario que devuelve un artículo comprado, debe tener los privilegios para cancelar una compra.
  #Cuando se cancela una compra, todos los artículos de esa compra son devueltos.
  has_many :compra_articulos_devueltos
  #El usuario que realiza una edicion de compra, debe tener los privilegios para realizarlo.
  has_many :historial_ediciones_compras

  #El usuario que realiza un pago por concepto de devolución de venta, debe tener los privilegios para realizarlo.
  has_many :pago_devolucions

  #El usuario que realiza un pago a proveedores, debe tener los privilegios para realizarlo.
  has_many :pago_proveedores

  has_many :gastos

  has_many :gasto_corrientes

  #Se trata del usuario que hace un retiro de efectivo de alguna de las cajas.
  has_many :retiro_caja_ventas

  has_many :movimiento_caja_sucursals

  #caja_chicas son los movimientos de caja chica los usuarios hacen. El tipo de movimientos que un usuario puede hacer son:
  #reposición o gasto.
  has_many :caja_chicas

  
  belongs_to :negocio

  belongs_to :sucursal

end
