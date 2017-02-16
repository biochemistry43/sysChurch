class CreateDatosFiscalesNegocios < ActiveRecord::Migration
  def change
    create_table :datos_fiscales_negocios do |t|
      t.string :nombreFiscal
      t.text :direccionFiscal
      t.string :rfc
      t.integer :negocio_id

      t.timestamps null: false
    end
  end
end
