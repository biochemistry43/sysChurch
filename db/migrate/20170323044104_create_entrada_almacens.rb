class CreateEntradaAlmacens < ActiveRecord::Migration
  def change
    create_table :entrada_almacens do |t|
      t.decimal :cantidad
      t.date :fecha
      t.boolean :isEntradaInicial
      t.integer :articulo_id
      t.integer :compra_id

      t.timestamps null: false
    end
  end
end
