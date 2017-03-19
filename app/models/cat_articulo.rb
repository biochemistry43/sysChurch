class CatArticulo < ActiveRecord::Base
	has_many :perdidas
	has_many :articulos
	has_many :cat_articulos
	belongs_to :cat_articulo

	validates :nombreCatArticulo, :presence => { message: "No puede ir vacío este campo" }
end
