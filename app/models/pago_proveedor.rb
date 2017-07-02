class PagoProveedor < ActiveRecord::Base
	belongs_to :gasto
	belongs_to :proveedor 
	belongs_to :compra
	belongs_to :sucursal
	belongs_to :negocio
	belongs_to :user
	belongs_to :pago_pendiente
end
