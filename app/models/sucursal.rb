class Sucursal < ActiveRecord::Base
	has_one :datos_fiscales_sucursal
	has_many :nota_creditos
	has_many :facturas
	has_many :factura_recurrentes

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
	has_many :gasto_generals
	has_many :retiro_caja_ventas
	has_many :caja_sucursals
	has_many :pago_pendientes

	#Se refiere a los registros de caja chica (no a varias cajas chicas)
	has_many :caja_chicas

	has_many :movimiento_caja_sucursals
end
