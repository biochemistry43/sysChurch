class DetalleCompra < ActiveRecord::Base
	belongs_to :articulo
	belongs_to :compra

	validates :cantidad_comprada, :precio_compra, :importe, :presence => { message: "Dato necesario" }
	validates :cantidad_comprada, :precio_compra, :importe, :numericality => { message: "campo numérico" }
	
end
