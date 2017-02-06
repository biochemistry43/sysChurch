class Venta < ActiveRecord::Base
	has_many :item_ventas
	has_one :venta_forma_pago
	belongs_to :user
end
