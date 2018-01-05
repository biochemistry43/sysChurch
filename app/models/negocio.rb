class Negocio < ActiveRecord::Base
	has_many :unidad_medidas
	has_many :factura_recurrentes
	has_many :facturas
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
	has_many :cat_compra_canceladas
	has_many :compra_canceladas
	has_many :compra_articulos_devueltos
	has_many :venta_canceladas
	has_many :historial_ediciones_compras
	has_many :pago_proveedores
	has_many :pago_devolucions
	has_many :gastos
	has_many :gasto_generals
	has_many :retiro_caja_ventas
	has_many :movimiento_caja_sucursals
	has_many :caja_chicas
	has_many :pago_pendientes
	has_many :proveedores
	has_many :caja_sucursals

end
