class Venta < ActiveRecord::Base
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

	def self.filtrar_por_forma_pago(ventas, forma_pago)
		ventas.select{|venta| venta.try(:movimiento_caja_sucursal).try(:tipo_pago).eql?(forma_pago.to_s)}
	end
end
