class AddSucursalToPerdida < ActiveRecord::Migration
  def change
    add_column :perdidas, :sucursal_id, :integer
  end
end
