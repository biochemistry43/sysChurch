class CreateAcuseCancelacions < ActiveRecord::Migration
  def change
    create_table :acuse_cancelacions do |t|
      t.string :folio
      t.string :comprobante
      t.integer :consecutivo
      t.date :fecha_cancelacion
      t.string :ruta_storage
      t.references :negocio, index: true, foreign_key: true
      t.references :sucursal, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
