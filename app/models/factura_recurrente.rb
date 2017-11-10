class FacturaRecurrente < ActiveRecord::Base
  belongs_to :user
  belongs_to :negocio
  belongs_to :sucursal
  belongs_to :cliente
  belongs_to :forma_pago
end
