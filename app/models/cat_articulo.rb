class CatArticulo < ActiveRecord::Base
	has_many :perdidas
	has_many :articulos
	has_many :car_articulos
	belongs_to :car_articulo
end
