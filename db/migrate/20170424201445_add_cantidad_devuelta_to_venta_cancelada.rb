class AddCantidadDevueltaToVentaCancelada < ActiveRecord::Migration
  def change
    add_column :venta_canceladas, :cantidad_devuelta, :decimal
  end
end
