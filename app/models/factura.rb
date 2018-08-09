class Factura < ActiveRecord::Base
  has_many :factura_nota_creditos
  has_one :factura_cancelada
  #has_many :ventas
  has_many :ventas
  belongs_to :user
  belongs_to :negocio
  belongs_to :sucursal
  belongs_to :cliente
  #belongs_to :forma_pago
  belongs_to :factura_forma_pago
  #validates :uso_cfdi_id, :presence => { message: "Este campo no puede ir vacío" }
end
