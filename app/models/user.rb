class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :tipo_usuario
  has_one :perfil
  has_many :ventas
  belongs_to :negocio
  belongs_to :sucursal
end
