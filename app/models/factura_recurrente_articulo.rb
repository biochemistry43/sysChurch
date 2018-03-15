class FacturaRecurrenteArticulo < ActiveRecord::Base
  belongs_to :factura_recurrente
  belongs_to :articulo
end
