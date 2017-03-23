class MarcaProducto < ActiveRecord::Base
	has_many :articulos

	validates :nombre, :presence => { message: "La marca debe llevar un nombre" }
	validates :nombre, uniqueness: { scope: :negocio_id, message: "Marca ya registrada" }
end
