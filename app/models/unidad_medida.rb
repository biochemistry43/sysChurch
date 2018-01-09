class UnidadMedida < ActiveRecord::Base
  has_many :articulos
	belongs_to :negocio
  validates :clave, :presence => { message: "No puede ir vacío este campo" }
  validates :nombre, :presence => { message: "No puede ir vacío este campo" }

  def nombre_simbolo_UM
    if simbolo.empty?
      "#{nombre} "
    else
      "#{nombre} [ #{simbolo} ]"
    end
  end

end
