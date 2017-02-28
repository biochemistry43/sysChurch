class Negocio < ActiveRecord::Base
	has_many :users
	has_many :sucursals
	has_many :clientes
	has_many :articulos
	has_one :datos_fiscales_negocio
end
