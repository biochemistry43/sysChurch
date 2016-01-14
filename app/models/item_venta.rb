class ItemVenta < ActiveRecord::Base
	belongs_to :venta
	belongs_to :articulo
end
