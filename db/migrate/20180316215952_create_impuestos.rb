class CreateImpuestos < ActiveRecord::Migration
  def change
    create_table :impuestos do |t|
      t.string :nombre
      t.string :tipo
      t.decimal :porcentaje
      t.text :descripcion

      t.timestamps null: false
    end
  end
end
