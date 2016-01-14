class Articulo < ActiveRecord::Base
	belongs_to :cat_articulo
	has_one :inventario
	has_many :entrada_inventario
end
