class Venta < ActiveRecord::Base
	belongs_to :factura
	has_many :item_ventas
	has_one :venta_forma_pago
	has_many :venta_canceladas

	#Cuando se hace una venta en efectivo, un registro de movmiento de caja de sucursal debe realizarse
	has_one :movimiento_caja_sucursal
	belongs_to :user
	belongs_to :cliente
	belongs_to :sucursal
	belongs_to :negocio
	belongs_to :caja_sucursal

	def monto_devolucion
      if self.venta_canceladas
        self.venta_canceladas.each do |devolucion|

        end
      end
	end
end
