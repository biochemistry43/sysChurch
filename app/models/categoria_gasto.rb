class CategoriaGasto < ActiveRecord::Base
	has_many :gasto
	belongs_to :negocio

	validates :nombreCategoria, :presence => { message: "La categoria debe tener un nombre" }
end
