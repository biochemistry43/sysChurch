class HistorialEdicionesCompra < ActiveRecord::Base
	belongs_to :compra
	belongs_to :user #Usuario que realiza la edición.
	belongs_to :negocio
	belongs_to :sucursal
end
