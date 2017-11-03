class CreateFacturas < ActiveRecord::Migration
  def change
    create_table :facturas do |t|
      t.string :folio
      t.datetime :fecha_expedicion
      t.string :estado_factura
      t.references :venta, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.references :negocio, index: true, foreign_key: true
      t.references :sucursal, index: true, foreign_key: true
      t.references :cliente, index: true, foreign_key: true
      t.references :forma_pago, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
