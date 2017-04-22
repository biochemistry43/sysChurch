class CatVentaCancelada < ActiveRecord::Base
	has_many :venta_canceladas
	belongs_to :negocio
end
