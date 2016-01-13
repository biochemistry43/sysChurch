class CreateEntradasInventario < ActiveRecord::Migration
  def change
    create_table :entradasInventario do |t|
      t.float :precioCompra
      t.float :precioVenta
      t.integer :cantidadComprada
      t.string :unidadMedida
      t.date :fechaIngreso
      t.integer :articulo_id
      t.integer :proveedor_id

      t.timestamps null: false
    end
  end
end
