class CreateVentaCanceladas < ActiveRecord::Migration
  def change
    create_table :venta_canceladas do |t|
      t.integer :articulo_id
      t.integer :item_venta_id
      t.integer :venta_id
      t.integer :cat_venta_cancelada_id
      t.integer :user_id
      t.date :fecha
      t.text :observaciones

      t.timestamps null: false
    end
  end
end
