class Venta < ActiveRecord::Base
	has_many :item_venta
	belongs_to :usuario
end
