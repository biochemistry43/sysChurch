class ItemVenta < ActiveRecord::Base
	belongs_to :venta
	belongs_to :articulo

	validates :cantidad, :presence
	validates :cantidad, :numericality
end
