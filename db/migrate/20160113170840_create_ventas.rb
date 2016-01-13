class CreateVentas < ActiveRecord::Migration
  def change
    create_table :ventas do |t|
      t.date :fechaVenta
      t.float :montoVenta

      t.timestamps null: false
    end
  end
end
