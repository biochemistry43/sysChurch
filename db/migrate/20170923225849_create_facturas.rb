class CreateFacturas < ActiveRecord::Migration
  def change
    create_table :facturas do |t|
      t.string :folio
      t.datetime :fecha_expedicion
      t.string :estado_factura
      t.integer :ventas_id
      t.integer :user_id
      t.integer :negocio_id
      t.integer :sucursal_id
      t.integer :cliente_id
      t.integer :forma_pago_id
      t.integer :metodo_pago_id

      t.timestamps null: false
    end
  end
end
