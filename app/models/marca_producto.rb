class MarcaProducto < ActiveRecord::Base
	has_many :articulos
	belongs_to :negocio

	validates :nombre, :presence => { "La marca debe llevar un nombre" }
end
