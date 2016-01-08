class CreateInventario < ActiveRecord::Migration
  def change
    create_table :inventario do |t|
      t.integer :cantidad
      t.string :unidad
      t.integer :articulo_id

      t.timestamps null: false
    end
  end
end
