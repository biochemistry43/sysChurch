class UnidadMedida < ActiveRecord::Base
  validates :clave, :presence => { message: "No puede ir vacío este campo" }
  validates :nombre, :presence => { message: "No puede ir vacío este campo" }

end
