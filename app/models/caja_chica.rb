class CajaChica < ActiveRecord::Base
	has_many :gastos
	
	belongs_to :user
	belongs_to :sucursal
	belongs_to :negocio
end
