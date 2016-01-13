class CreateItemVentas < ActiveRecord::Migration
  def change
    create_table :item_ventas do |t|
      t.integer :venta_id
      t.integer :articulo_id

      t.timestamps null: false
    end
  end
end
