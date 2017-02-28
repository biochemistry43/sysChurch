class Sucursal < ActiveRecord::Base
	has_many :users
	has_many :articulos
	has_many :gastos
	has_many :perdidas
	has_many :proveedores
	has_many :ventas
	belongs_to :negocio
	has_one :datos_fiscales_sucursal
end
