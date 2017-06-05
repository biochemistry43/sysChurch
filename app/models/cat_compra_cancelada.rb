class CatCompraCancelada < ActiveRecord::Base
	has_many :compra_canceladas
	belongs_to :negocio
end
