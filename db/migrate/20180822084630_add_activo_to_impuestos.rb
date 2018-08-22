class AddActivoToImpuestos < ActiveRecord::Migration
  def change
    add_column :impuestos, :activo, :boolean
  end
end
