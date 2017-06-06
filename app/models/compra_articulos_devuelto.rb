#Este modelo controla la tabla que registra todos los artículos que fueron comprados y posteriormente devueltos.
#Este registro puede llenarse por la cancelación total de la compra en la que esté incluido dicho artículo o 
#por una devolución parcial.
class CompraArticulosDevuelto < ActiveRecord::Base
	belongs_to :negocio
	belongs_to :sucursal
	belongs_to :user #El usuario al que pertenece es el que autoriza la cancelación.
    belongs_to :articulo
    belongs_to :detalle_compra
    belongs_to :compra
    belongs_to :cat_compra_cancelada
end
