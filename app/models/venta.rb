class Venta < ActiveRecord::Base
	has_many :item_venta
	has_one :venta_forma_pago
	belongs_to :user
end
