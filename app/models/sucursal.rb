class Sucursal < ActiveRecord::Base
	has_many :users
	has_many :articulos
	has_many :gastos
	has_many :perdidas
	has_many :proveedores
	has_many :ventas
	has_many :compras
	has_many :compra_canceladas
	belongs_to :negocio
	has_one :datos_fiscales_sucursal
	has_many :venta_canceladas
end
