class CreateHistorialEdicionesCompras < ActiveRecord::Migration
  def change
    create_table :historial_ediciones_compras do |t|
      t.integer :compra_id
      t.integer :sucursal_id
      t.integer :negocio_id
      t.integer :user_id
      t.decimal :monto_anterior

      t.timestamps null: false
    end
  end
end
