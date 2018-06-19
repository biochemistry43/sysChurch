class NotaCredito < ActiveRecord::Base
  belongs_to :factura
  belongs_to :user
  belongs_to :cliente
  belongs_to :sucursal
  belongs_to :negocio

end
