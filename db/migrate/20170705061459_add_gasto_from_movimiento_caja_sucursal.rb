class AddGastoFromMovimientoCajaSucursal < ActiveRecord::Migration
  def change
    add_column :movimiento_caja_sucursals, :gasto_id, :integer
  end
end
