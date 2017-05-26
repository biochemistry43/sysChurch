class CreateCatCompraCanceladas < ActiveRecord::Migration
  def change
    create_table :cat_compra_canceladas do |t|
      t.string :clave
      t.string :descripcion
      t.integer :negocio_id

      t.timestamps null: false
    end
  end
end
