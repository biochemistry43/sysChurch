class MovimientoCajaSucursal < ActiveRecord::Base
	belongs_to :venta
	has_many :gastos
	has_one :retiros_caja_venta
end
