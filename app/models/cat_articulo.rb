class CatArticulo < ActiveRecord::Base
	has_many :perdidas
	has_many :articulos
end
