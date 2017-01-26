class Usuario < ActiveRecord::Base
	belongs_to :tipo_usuario
	belongs_to :persona
	has_many :ventas
	has_many :bancos
end
