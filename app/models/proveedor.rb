class Proveedor < ActiveRecord::Base
	 has_many :entradasinventario
	 belongs_to :sucursal

	 validates :nombre, :presence => { message: "Campo obligatorio" }
end
