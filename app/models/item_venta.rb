class ItemVenta < ActiveRecord::Base
	belongs_to :venta
	belongs_to :articulo
	has_many :venta_canceladas


end
