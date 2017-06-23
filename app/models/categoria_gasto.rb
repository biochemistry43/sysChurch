class CategoriaGasto < ActiveRecord::Base
	belongs_to :negocio
	has_many :gastos

	validates :nombreCategoria, :presence => { message: "La categoria debe tener un nombre" }
	validates :nombreCategoria, uniqueness: { scope: :negocio_id, message: "Esta categoría ya existe" }
end
