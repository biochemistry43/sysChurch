class ClaveProdServ < ActiveRecord::Base
  has_many :articulos
  belongs_to :negocio
  
  def clave_nomb_producto
   "#{clave} - #{nombre}"
 end
end
