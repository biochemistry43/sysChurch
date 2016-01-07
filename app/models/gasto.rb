class Gasto < ActiveRecord::Base
	belongs_to :persona
	belongs_to :categoria_gasto
end
