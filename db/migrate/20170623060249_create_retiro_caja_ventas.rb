class CreateRetiroCajaVentas < ActiveRecord::Migration
  def change
    create_table :retiro_caja_ventas do |t|
      t.decimal :monto_retirado
      t.integer :user_id
      t.integer :sucursal_id
      t.integer :negocio_id
      t.integer :caja_ventas_id

      t.timestamps null: false
    end
  end
end
