class AddSucursalToUser < ActiveRecord::Migration
  def change
    add_column :users, :sucursal_id, :integer
  end
end
