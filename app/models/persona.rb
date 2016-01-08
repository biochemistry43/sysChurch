class Persona < ActiveRecord::Base
	has_one :usuario
	has_many :gasto
end
