class Compra < ActiveRecord::Base
	has_many :detalle_compras
	has_many :entrada_almacens
	has_one :compra_cancelada
	has_many :compra_articulos_devueltos
	has_many :historial_ediciones_compras
	has_many :pago_proveedores
	has_one :pago_pendiente
	belongs_to :proveedor
	belongs_to :user
	belongs_to :sucursal
	belongs_to :negocio
	belongs_to :gasto

	validates_associated :detalle_compras

	validates :fecha, :monto_compra, :proveedor_id, :tipo_pago, :folio_compra, :ticket_compra, :presence => { message: "Dato necesario para la compra" }
    validates :monto_compra, numericality: { greater_than: 0, message: "El monto de compra no puede ser cero" }
	
end
