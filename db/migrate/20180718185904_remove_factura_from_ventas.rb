class RemoveFacturaFromVentas < ActiveRecord::Migration
  def change
    remove_reference :ventas, :factura, index: true, foreign_key: true
  end
end
