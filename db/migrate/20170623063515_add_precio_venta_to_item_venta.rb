class AddPrecioVentaToItemVenta < ActiveRecord::Migration
  def change
    add_column :item_ventas, :precio_venta, :decimal
  end
end
