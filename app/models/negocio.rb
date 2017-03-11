class Negocio < ActiveRecord::Base
	mount_uploader :logo, FotoProductoUploader
	has_many :users
	has_many :sucursals
	has_many :clientes
	has_many :bancos
	has_many :cat_articulos
	has_many :categoria_gastos
	has_many :categoria_perdidas
	has_one :datos_fiscales_negocio
end
