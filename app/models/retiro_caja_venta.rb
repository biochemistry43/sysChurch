class RetiroCajaVenta < ActiveRecord::Base
	belongs_to :caja_venta
	belongs_to :user
	belongs_to :sucursal
	belongs_to :negocio
end
