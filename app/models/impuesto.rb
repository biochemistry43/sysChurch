class Impuesto < ActiveRecord::Base
  has_many :articulos
  belongs_to :negocio

  def impuesto_porcentaje_tipo
   "#{nombre} - #{porcentaje}% (#{tipo})"
 end
end
