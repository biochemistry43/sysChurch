class AddTipoPagoToMovimientoCajaSucursal < ActiveRecord::Migration
  def change
    add_column :movimiento_caja_sucursals, :tipo_pago, :string
  end
end
