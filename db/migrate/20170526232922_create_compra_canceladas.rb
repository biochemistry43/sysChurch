class CreateCompraCanceladas < ActiveRecord::Migration
  def change
    create_table :compra_canceladas do |t|
      t.integer :articulo_id
      t.integer :detalle_compra
      t.integer :compra_id
      t.integer :cat_compra_cancelada
      t.integer :user_id
      t.date :fecha
      t.string :observaciones
      t.integer :negocio_id
      t.integer :sucursal_id
      t.decimal :cantidad_devuelta

      t.timestamps null: false
    end
  end
end
