class Persona < ActiveRecord::Base
	belongs_to :user
	has_many :telefono_personas
end
