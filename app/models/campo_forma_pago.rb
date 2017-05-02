class CampoFormaPago < ActiveRecord::Base
	belongs_to :forma_pago
	has_many :venta_forma_pago_campos
	has_many :campo_forma_pago_items
end
