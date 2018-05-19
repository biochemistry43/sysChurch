class CreateFacturaRecurrenteArticulos < ActiveRecord::Migration
  def change
    create_table :factura_recurrente_articulos do |t|
      t.references :factura_recurrente, index: true, foreign_key: true
      t.references :articulo, index: true, foreign_key: true
      t.decimal :cantidad
      t.decimal :precio
      t.decimal :monto

      t.timestamps null: false
    end
  end
end
