class AddFacturaToVentas < ActiveRecord::Migration
  def change
    add_reference :ventas, :factura, index: true, foreign_key: true
  end
end
