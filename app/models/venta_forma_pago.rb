class VentaFormaPago < ActiveRecord::Base
    has_many :venta_forma_pago_campos
	belongs_to :venta
	belongs_to :forma_pago
end
