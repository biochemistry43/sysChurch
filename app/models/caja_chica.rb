class CajaChica < ActiveRecord::Base
	has_one :gasto
	
	belongs_to :user
	belongs_to :sucursal
	belongs_to :negocio
end
