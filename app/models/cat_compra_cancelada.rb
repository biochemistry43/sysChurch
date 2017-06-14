class CatCompraCancelada < ActiveRecord::Base
	has_many :compra_canceladas
	has_many :compra_articulos_devueltos
	belongs_to :negocio

	validates :clave, :presence => { message: "Este dato es obligatorio" }
end
