class PresentacionProducto < ActiveRecord::Base
	has_many :articulos
	belongs_to :negocio

	validates :nombre, :presence=>{ message: "Este campo no puede ir vacío"}
	validates :nombre, uniqueness: { scope: :negocio_id, message: "Presentación ya registrada" }
end
