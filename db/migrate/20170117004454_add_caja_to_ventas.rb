class AddCajaToVentas < ActiveRecord::Migration
  def change
    add_column :ventas, :caja, :integer
  end
end
