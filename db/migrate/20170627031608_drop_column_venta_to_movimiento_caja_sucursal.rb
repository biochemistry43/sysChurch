class DropColumnVentaToMovimientoCajaSucursal < ActiveRecord::Migration
  def change
  	remove_column :movimiento_caja_sucursals, :venta_id, :integer
  end
end
