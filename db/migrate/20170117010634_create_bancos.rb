class CreateBancos < ActiveRecord::Migration
  def change
    create_table :bancos do |t|
      t.string :tipoCuenta
      t.string :nombreCuenta
      t.integer :numeroCuenta
      t.decimal :saldoInicial
      t.date :fecha
      t.text :descripcion

      t.timestamps null: false
    end
  end
end
