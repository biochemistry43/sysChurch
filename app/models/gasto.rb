class Gasto < ActiveRecord::Base
	belongs_to :categoria_gasto
	belongs_to :sucursal
end
