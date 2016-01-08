class CatArticulo < ActiveRecord::Base
	has_many :perdida
	has_many :articulo
end
