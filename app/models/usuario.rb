class Usuario < ActiveRecord::Base
	belongs_to :tipo_usuario
	has_one :persona
	has_many :ventas
	has_many :bancos
	has_many :mermas
end
