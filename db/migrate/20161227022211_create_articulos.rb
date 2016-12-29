class CreateArticulos < ActiveRecord::Migration
  def change
    create_table :articulos do |t|
      t.string :clave
      t.string :nombre
      t.string :descripcion
      t.integer :stock
      t.integer :cat_articulo_id

      t.timestamps null: false
    end
  end
end
