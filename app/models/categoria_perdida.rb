class CategoriaPerdida < ActiveRecord::Base
	has_many :perdida
	belongs_to :negocio

	validates :nombreCatPerdida, :presence => { message: "La categoria debe tener un nombre" }
	validates :nombreCatPerdida, uniqueness: { scope: :negocio_id, message: "Esta categoría ya existe" }
end


