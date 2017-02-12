class Sucursal < ActiveRecord::Base
	has_many :users
	belongs_to :negocio
end
