class CategoriaGasto < ActiveRecord::Base
	has_many :gasto
	belongs_to :negocio

	validates :nombreCategoria, :presence => { message: "La categoria debe tener un nombre" }
	validates :nombreCategoria, uniqueness: { scope: :negocio_id, message: "Esta categoría ya existe" }
end
