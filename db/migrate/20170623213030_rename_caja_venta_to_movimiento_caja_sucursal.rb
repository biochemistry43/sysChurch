class RenameCajaVentaToMovimientoCajaSucursal < ActiveRecord::Migration
  def change
  	rename_table :caja_ventas, :movimientos_caja_sucursal
  end
end
