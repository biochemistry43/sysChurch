class Negocio < ActiveRecord::Base
	mount_uploader :logo, FotoProductoUploader
	has_many :users
	has_many :sucursals
	has_many :articulos
	has_many :clientes
	has_many :bancos
	has_many :cat_articulos
	has_many :categoria_gastos
	has_many :categoria_perdidas
	has_one :datos_fiscales_negocio
	has_many :marca_productos
	has_many :presentacion_productos
	has_many :ventas
	has_many :compras
	has_many :cat_venta_canceladas
	has_many :venta_canceladas
end
