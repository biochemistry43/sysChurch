class CreateFacturaRecurrentes < ActiveRecord::Migration
  def change
    create_table :factura_recurrentes do |t|
      t.string :folio
      t.date :fecha_expedicion
      t.string :estado_factura
      t.integer :tiempo_recurrente
      t.references :user, index: true, foreign_key: true
      t.references :negocio, index: true, foreign_key: true
      t.references :sucursal, index: true, foreign_key: true
      t.references :cliente, index: true, foreign_key: true
      t.references :forma_pago, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
