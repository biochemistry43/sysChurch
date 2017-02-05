class AddColumnCantidadToItemVenta < ActiveRecord::Migration
  def change
    add_column :item_ventas, :cantidad, :decimal
  end
end
