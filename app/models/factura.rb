class Factura < ActiveRecord::Base
  belongs_to :venta
  belongs_to :user
  belongs_to :negocio
  belongs_to :sucursal
  belongs_to :cliente
  belongs_to :forma_pago
  #validates :uso_cfdi_id, :presence => { message: "Este campo no puede ir vacío" }
end
