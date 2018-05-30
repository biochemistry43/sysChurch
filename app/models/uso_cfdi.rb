class UsoCfdi < ActiveRecord::Base
  validates :clave, :presence => { message: "No puede ir vacío este campo" }
  validates :descripcion, :presence => { message: "No puede ir vacío este campo" }
  def clave_descripcion_uso_cfdi
      "#{clave} - #{descripcion}"
  end
end
