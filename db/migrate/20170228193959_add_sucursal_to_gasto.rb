class AddSucursalToGasto < ActiveRecord::Migration
  def change
    add_column :gastos, :sucursal_id, :integer
  end
end
