class VentaFormaPagoCampo < ActiveRecord::Base
	belongs_to :venta_forma_pago
	belongs_to :campo_forma_pago
end
