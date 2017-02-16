class CreateDatosFiscalesSucursals < ActiveRecord::Migration
  def change
    create_table :datos_fiscales_sucursals do |t|
      t.string :nombreFiscal
      t.text :direccionFiscal
      t.string :rfc
      t.integer :sucursal_id

      t.timestamps null: false
    end
  end
end
