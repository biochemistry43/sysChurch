class CreateFacturaGlobals < ActiveRecord::Migration
  def change
    create_table :factura_globals do |t|
      t.string :folio
      t.date :fecha_expedicion
      t.string :estado_factura
      t.references :user, index: true, foreign_key: true
      t.references :negocio, index: true, foreign_key: true
      t.references :sucursal, index: true, foreign_key: true
      t.string :folio_fiscal
      t.integer :consecutivo
      t.string :ruta_storage
      t.references :factura_forma_pago, index: true, foreign_key: true
      t.decimal :monto

      t.timestamps null: false
    end
  end
end
