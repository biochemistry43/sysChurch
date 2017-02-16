class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :tipo_usuario
  has_one :persona
  has_many :ventas
  has_many :bancos
  belongs_to :negocio
  belongs_to :sucursal
end
