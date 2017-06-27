class CajaSucursal < ActiveRecord::Base
	belongs_to :sucursal
	has_many :gastos
	has_many :movimiento_caja_sucursals

	validates :numero_caja, :nombre, :presence => {message: "No puede dejarse vacío este campo"}
end
