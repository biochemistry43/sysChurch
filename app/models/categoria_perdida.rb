class CategoriaPerdida < ActiveRecord::Base
	has_many :perdida
	belongs_to :negocio
end
