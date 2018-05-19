class MetodoPago < ActiveRecord::Base
  validates :clave, :presence => { message: "Este campo no puede ir vacío" }
  validates :descripcion, :presence => { message: "Este campo no puede ir vacío" }
end
