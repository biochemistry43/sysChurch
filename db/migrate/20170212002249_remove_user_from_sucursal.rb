class RemoveUserFromSucursal < ActiveRecord::Migration
  def change
    remove_column :sucursals, :user_id, :integer
  end
end
