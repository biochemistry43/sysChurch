class CreateMarcaProductos < ActiveRecord::Migration
  def change
    create_table :marca_productos do |t|
      t.string :nombre

      t.timestamps null: false
    end
  end
end
