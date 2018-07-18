class AddFacturaGlobalToVentas < ActiveRecord::Migration
  def change
    add_reference :ventas, :factura_global, index: true, foreign_key: true
  end
end
