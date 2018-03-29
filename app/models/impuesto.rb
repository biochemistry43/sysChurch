class Impuesto < ActiveRecord::Base
  belongs_to :negocio
  has_one :articulo

  def impuesto_porcentaje_tipo
   "#{nombre} - #{porcentaje}% (#{tipo})"
 end
end
