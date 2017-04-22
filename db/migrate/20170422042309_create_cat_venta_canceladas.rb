class CreateCatVentaCanceladas < ActiveRecord::Migration
  def change
    create_table :cat_venta_canceladas do |t|
      t.string :clave
      t.string :descripcion

      t.timestamps null: false
    end
  end
end
