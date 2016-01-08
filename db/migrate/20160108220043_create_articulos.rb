class CreateArticulos < ActiveRecord::Migration
  def change
    create_table :articulos do |t|
      t.string :nombreArticulo
      t.string :descripcionArticulo
      t.integer :stockRequerido
      t.integer :cat_articulo_id

      t.timestamps null: false
    end
  end
end
