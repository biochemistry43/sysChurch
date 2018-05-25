class CreateMermas < ActiveRecord::Migration
  def change
    create_table :mermas do |t|
      t.string :motivo_baja
      t.decimal :cantidad_merma
      t.datetime :fecha_hora
      t.integer :articulo_id
      t.integer :cat_merma_id
      t.integer :user_id
      t.integer :sucursal_id
      t.integer :negocio_id

      t.timestamps null: false
    end
  end
end
