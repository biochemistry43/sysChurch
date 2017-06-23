class RenameMovimientoCajaSucursalToMovimientoCajaSucursal < ActiveRecord::Migration
  def change
  	rename_table :movimientos_caja_sucursal, :movimiento_caja_sucursals
  end
end
