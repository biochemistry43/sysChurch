class CreateDatosFiscalesClientes < ActiveRecord::Migration
  def change
    create_table :datos_fiscales_clientes do |t|
      t.string :nombreFiscal
      t.text :direccionFiscal
      t.string :rfc
      t.string :cliente_id

      t.timestamps null: false
    end
  end
end
