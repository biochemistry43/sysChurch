class AddVentaToMovimientoCajaSucursal < ActiveRecord::Migration
  def change
    add_column :movimiento_caja_sucursals, :venta_id, :integer
  end
end
