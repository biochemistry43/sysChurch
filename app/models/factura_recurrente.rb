class FacturaRecurrente < ActiveRecord::Base
  belongs_to :user
  belongs_to :negocio
  belongs_to :sucursal
  belongs_to :cliente
  belongs_to :forma_pago
  has_many :factura_recurrente_articulos
  #validates :nombre, :presence => { message: "Este campo no puede ir vacío" }
end
