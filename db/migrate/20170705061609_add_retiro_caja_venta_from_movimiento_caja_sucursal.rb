class AddRetiroCajaVentaFromMovimientoCajaSucursal < ActiveRecord::Migration
  def change
    add_column :movimiento_caja_sucursals, :retiro_caja_venta_id, :integer
  end
end
