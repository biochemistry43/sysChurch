class Compra < ActiveRecord::Base
	has_many :detalle_compras
	has_many :entrada_almacens
	belongs_to :proveedor
	belongs_to :user

	validates :fecha, :tipo_pago, :folio_compra, :presence => { message: "Dato necesario para la compra" }
	
end
