class MovimientoCajaSucursal < ActiveRecord::Base
	#No todos los registros de venta serán replicados en los registros de caja de sucursal pues hay ventas que pueden
	#hacerse en diferentes cajas y por diferentes formas de pago. En este modelo se registran únicamente los cobros realizados
	#en efectivo.
	#De cualquier manera, no todos los registros de movimiento de caja de sucursal tienen una relación con una venta.
	#Los registros de salida de efectivo no tendrán relación con ninguna venta sino con un gasto.
	#Además, no todos los registros de entrada son por concepto de venta, pues también puede haber "reposiciones de caja"
	#Para asignar un monto inicial al cajero, etc.
	belongs_to :venta
	belongs_to :user
	belongs_to :negocio
	belongs_to :sucursal
	belongs_to :caja_sucursal
	belongs_to :gasto
	belongs_to :retiro_caja_venta
end
