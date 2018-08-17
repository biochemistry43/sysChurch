class AcuseCancelacion < ActiveRecord::Base
  belongs_to :negocio
  belongs_to :sucursal
  belongs_to :user
end
