class CreatePresentacionProductos < ActiveRecord::Migration
  def change
    create_table :presentacion_productos do |t|
      t.string :nombre

      t.timestamps null: false
    end
  end
end
