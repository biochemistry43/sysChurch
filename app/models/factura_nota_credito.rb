class FacturaNotaCredito < ActiveRecord::Base
  belongs_to :factura
  belongs_to :nota_credito
end
