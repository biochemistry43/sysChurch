class Factura < ActiveRecord::Base
  belongs_to :venta
  belongs_to :user
  belongs_to :negocio
  belongs_to :sucursal
  belongs_to :cliente
  belongs_to :forma_pago
end
