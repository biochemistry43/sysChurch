class PagoDevolucion < ActiveRecord::Base
	belongs_to :gasto
	belongs_to :devolucion
	belongs_to :user
	belongs_to :sucursal
	belongs_to :negocio
	belongs_to :venta_cancelada
end
