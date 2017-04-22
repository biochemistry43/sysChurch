class ItemVenta < ActiveRecord::Base
	belongs_to :venta
	belongs_to :articulo
	has_one :venta_cancelada


end
