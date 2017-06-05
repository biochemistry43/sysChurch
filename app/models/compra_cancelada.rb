class CompraCancelada < ActiveRecord::Base
	belongs_to :negocio
	belongs_to :sucursal
	belongs_to :user #El usuario al que pertenece es el que autoriza la cancelación.
    belongs_to :articulo
    belongs_to :detalle_compra
    belongs_to :compra
    belongs_to :cat_compra_cancelada
end
