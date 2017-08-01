class CategoriaGasto < ActiveRecord::Base
	belongs_to :negocio
	has_many :gastos

	validates :nombre_categoria, :presence => { message: "La categoria debe tener un nombre" }
	validates :nombre_categoria, uniqueness: { scope: :negocio_id, message: "Esta categoría ya existe" }
end
