class CajaSucursal < ActiveRecord::Base
	belongs_to :sucursal
	belongs_to :user
	has_many :gastos
	has_many :movimiento_caja_sucursals
	has_many :ventas

	validates :numero_caja, :nombre, :presence => {message: "No puede dejarse vacío este campo"}
end
