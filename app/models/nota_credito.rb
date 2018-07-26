class NotaCredito < ActiveRecord::Base
  belongs_to :factura
  belongs_to :user
  belongs_to :cliente
  belongs_to :sucursal
  belongs_to :negocio
  belongs_to :factura_forma_pago
  has_one :nota_credito_cancelada
end
