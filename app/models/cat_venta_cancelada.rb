class CatVentaCancelada < ActiveRecord::Base
	has_many :venta_canceladas
	belongs_to :negocio

	validates :clave, :presence => { message: "Este dato es obligatorio" }
end
