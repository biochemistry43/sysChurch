class CreateFacturaNotaCreditos < ActiveRecord::Migration
  def change
    create_table :factura_nota_creditos do |t|
      t.references :factura, index: true, foreign_key: true
      t.references :nota_credito, index: true, foreign_key: true
      t.string :estado_fv
      t.string :estado_nc
      t.string :monto_fv

      t.timestamps null: false
    end
  end
end
