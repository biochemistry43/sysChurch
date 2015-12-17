class CreateTipoUsuarios < ActiveRecord::Migration
  def change
    create_table :tipo_usuarios do |t|
      t.string :nombreTipo
      t.string :descripcionTipo
      t.boolean :isVentas
      t.boolean :isInventarios
      t.boolean :isPerdidas
      t.boolean :isPersonas
      t.boolean :isGastos

      t.timestamps null: false
    end
  end
end
