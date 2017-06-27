class RemoveSaldoToMovimientoCajaSucursal < ActiveRecord::Migration
  def change
    remove_column :movimiento_caja_sucursals, :saldo, :string
  end
end
