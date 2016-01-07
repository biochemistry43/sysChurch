class CreatePerdidas < ActiveRecord::Migration
  def change
    create_table :perdidas do |t|
      t.string :descripcionPerdida
      t.date :fechaPerdida
      t.string :nombreArticuloPerdida
      t.float :precioCompraArticuloPerdida
      t.float :precioVentaArticuloPerdida
      t.integer :categoriaPerdida_id
      t.integer :catArticulo_id

      t.timestamps null: false
    end
  end
end
