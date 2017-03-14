class CatArticulo < ActiveRecord::Base
	has_many :perdidas
	has_many :articulos
	has_many :cat_articulos
	belongs_to :cat_articulo
end
