class FacturaGlobal < ActiveRecord::Base
  belongs_to :user
  belongs_to :negocio
  belongs_to :sucursal
  belongs_to :factura_forma_pago
end
