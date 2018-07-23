class NotaCreditoCancelada < ActiveRecord::Base
  belongs_to :negocio
  belongs_to :sucursal
  belongs_to :user
  belongs_to :nota_credito
end
