class Negocio < ActiveRecord::Base
	has_many :users
	has_many :sucursals
end
