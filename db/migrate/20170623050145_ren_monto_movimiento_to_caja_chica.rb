class RenMontoMovimientoToCajaChica < ActiveRecord::Migration
  def change
  	rename_column :caja_chicas, :monto_movimiento, :entrada
  	add_column :caja_chicas, :salida, :decimal
  end
end
