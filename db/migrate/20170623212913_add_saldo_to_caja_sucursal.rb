class AddSaldoToCajaSucursal < ActiveRecord::Migration
  def change
    add_column :caja_sucursals, :saldo, :decimal
  end
end
