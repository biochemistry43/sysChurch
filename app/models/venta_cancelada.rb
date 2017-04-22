class VentaCancelada < ActiveRecord::Base
  belongs_to :user #El usuario al que pertenece es el que autoriza la cancelación.
  belongs_to :sucursal
  belongs_to :negocio
  belongs_to :articulo
  belongs_to :item_venta
  belongs_to :venta
  belongs_to :cat_venta_cancelada
  
end
