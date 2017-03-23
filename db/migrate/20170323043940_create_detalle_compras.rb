class CreateDetalleCompras < ActiveRecord::Migration
  def change
    create_table :detalle_compras do |t|
      t.decimal :cantidad_comprada
      t.decimal :precio_compra
      t.decimal :importe
      t.integer :compra_id
      t.integer :articulo_id

      t.timestamps null: false
    end
  end
end
