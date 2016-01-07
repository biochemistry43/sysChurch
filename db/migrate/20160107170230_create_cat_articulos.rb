class CreateCatArticulos < ActiveRecord::Migration
  def change
    create_table :cat_articulos do |t|
      t.string :nombreCatArticulo
      t.string :descripcionCatArticulo
      t.integer :idCategoriaPadre

      t.timestamps null: false
    end
  end
end
