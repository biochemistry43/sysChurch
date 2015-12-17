class Usuario < ActiveRecord::Base
	belongs_to :tipo_usuario
	belongs_to :persona
end
