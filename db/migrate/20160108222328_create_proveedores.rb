class CreateProveedores < ActiveRecord::Migration
  def change
    create_table :proveedores do |t|
      t.string :nombreProveedor
      t.string :telProveedor
      t.string :emailProveedor

      t.timestamps null: false
    end
  end
end
