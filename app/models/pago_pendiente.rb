class PagoPendiente < ActiveRecord::Base
	belongs_to :compra
	belongs_to :proveedor
	belongs_to :sucursal
	belongs_to :negocio
	has_many :pago_proveedores
end
