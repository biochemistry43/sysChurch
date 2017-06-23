class Proveedor < ActiveRecord::Base
	 belongs_to :sucursal
	 has_many :compras
	 has_many :pago_proveedores
	 has_many :gasto_corrientes

	 validates :nombre, :presence => { message: "Campo obligatorio" }
end
