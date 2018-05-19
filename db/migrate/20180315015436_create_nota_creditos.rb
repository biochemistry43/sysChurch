class CreateNotaCreditos < ActiveRecord::Migration
  def change
    create_table :nota_creditos do |t|
      t.string :folio
      t.date :fecha_expedicion
      t.decimal :monto_devolucion
      t.string :motivo
      t.references :user, index: true, foreign_key: true
      t.references :cliente, index: true, foreign_key: true
      t.references :sucursal, index: true, foreign_key: true
      t.references :negocio, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
