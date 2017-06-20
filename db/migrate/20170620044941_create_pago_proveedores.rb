class CreatePagoProveedores < ActiveRecord::Migration
  def change
    create_table :pago_proveedores do |t|
      t.decimal :monto
      t.integer :compra_id
      t.integer :gasto_id
      t.integer :proveedor_id
      t.integer :usuario_id
      t.integer :sucursal_id
      t.integer :negocio_id

      t.timestamps null: false
    end
  end
end
