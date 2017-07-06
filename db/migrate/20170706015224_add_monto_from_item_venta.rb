class AddMontoFromItemVenta < ActiveRecord::Migration
  def change
    add_column :item_ventas, :monto, :decimal
  end
end
