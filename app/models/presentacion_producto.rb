class PresentacionProducto < ActiveRecord::Base
	has_many :articulos
	belongs_to :negocio

	validates :nombre, :presence=>{ message: "Este campo no puede ir vacío"}
end
