class CategoriaGasto < ActiveRecord::Base
	has_many :gasto
	belongs_to :negocio
	
end
