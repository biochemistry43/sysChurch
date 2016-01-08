class Articulo < ActiveRecord::Base
	belongs_to :cat_articulo
	has_one :inventario
	has_one :entrada_inventario
end
