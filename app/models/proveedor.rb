class Proveedor < ActiveRecord::Base
	 belongs_to :sucursal
	 has_many :compras

	 validates :nombre, :presence => { message: "Campo obligatorio" }
end
