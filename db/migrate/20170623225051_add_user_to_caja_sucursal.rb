class AddUserToCajaSucursal < ActiveRecord::Migration
  def change
  	add_column :caja_sucursals, :user_id, :integer
  end
end
