class Gasto < ActiveRecord::Base
	has_one :pago_devolucion
	has_one :pago_proveedor
	has_one :gasto_general
	has_one :movimiento_caja_sucursal

	#En caso de que el pago se haya hecho con la caja chica, el registro de gasto se relacionará
	#con el registro de movimiento de la caja chica.
	belongs_to :caja_chica

	#En caso de que el pago se haya hecho con la caja de venta, el registro de gasto se relacionará
	#con el registro de movimiento de la caja de venta.
	belongs_to :caja_sucursal

	#Se trata del usuario que registra el gasto
	belongs_to :user

	belongs_to :categoria_gasto
	belongs_to :sucursal
	belongs_to :negocio


end
