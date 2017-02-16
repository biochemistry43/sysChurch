class Cliente < ActiveRecord::Base
	belongs_to :negocio
	has_one :datos_fiscales_cliente
	has_many :ventas
end
