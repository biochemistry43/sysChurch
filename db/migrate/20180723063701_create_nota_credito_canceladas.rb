class CreateNotaCreditoCanceladas < ActiveRecord::Migration
  def change
    create_table :nota_credito_canceladas do |t|
      t.datetime :fecha_cancelacion
      t.string :ruta_storage
      t.references :negocio, index: true, foreign_key: true
      t.references :sucursal, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.references :nota_credito, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
