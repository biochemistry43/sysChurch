class CompraCancelada < ActiveRecord::Base
	belongs_to :compra
	belongs_to :user
	belongs_to :cat_compra_cancelada
end
