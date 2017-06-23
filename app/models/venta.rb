class Venta < ActiveRecord::Base
	has_many :item_ventas
	has_one :venta_forma_pago
	has_many :venta_canceladas
	has_many :movimiento_caja_sucursals
	belongs_to :user
	belongs_to :cliente
	belongs_to :sucursal
	belongs_to :negocio
end
