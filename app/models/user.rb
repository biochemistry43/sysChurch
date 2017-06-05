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
  belongs_to :negocio
  belongs_to :sucursal
end
