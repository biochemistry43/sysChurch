class Proveedor < ActiveRecord::Base
	 belongs_to :sucursal
	 belongs_to :negocio
	 has_many :compras
	 has_many :pago_proveedores
	 has_many :gasto_corrientes
	 has_many :pago_pendientes

	 validates :nombre, :presence => { message: "Campo obligatorio" }
end
