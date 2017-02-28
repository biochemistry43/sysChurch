class Sucursal < ActiveRecord::Base
	has_many :users
	has_many :articulos
	belongs_to :negocio
	has_one :datos_fiscales_sucursal
end
