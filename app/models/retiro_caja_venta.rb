class RetiroCajaVenta < ActiveRecord::Base
	belongs_to :caja_venta
	belongs_to :user
	belongs_to :sucursal
	belongs_to :negocio

	has_one :movimiento_caja_sucursal
end
