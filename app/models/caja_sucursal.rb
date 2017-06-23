class CajaSucursal < ActiveRecord::Base
	belongs_to :sucursal

	validates :numero_caja, :nombre, :presence => {message: "No puede dejarse vacío este campo"}
end
