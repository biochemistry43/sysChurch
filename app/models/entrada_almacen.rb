class EntradaAlmacen < ActiveRecord::Base
	belongs_to :compra
	belongs_to :articulo

	validates :cantidad, :fecha, :isEntradaInicial, :presence => { :message "Campos necesarios" }
	validates :cantidad, :numericality => { message: "campo numérico" }
end
