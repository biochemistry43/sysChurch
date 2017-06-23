class Sucursal < ActiveRecord::Base
	has_many :users
	has_many :articulos
	has_many :gastos
	has_many :perdidas
	has_many :proveedores
	has_many :ventas
	has_many :compras
	has_many :compra_canceladas
	has_many :compra_articulos_devueltos
	belongs_to :negocio
	has_one :datos_fiscales_sucursal
	has_many :venta_canceladas
	has_many :historial_ediciones_compras
	has_many :pago_proveedores
	has_many :pago_devolucions
	has_many :gasto_corrientes
	has_many :retiro_caja_ventas
end
