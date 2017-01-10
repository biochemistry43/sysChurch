class CreateProveedores < ActiveRecord::Migration
  def change
    create_table :proveedores do |t|
      t.string :nombre
      t.string :telefono
      t.string :email

      t.timestamps null: false
    end
  end
end
