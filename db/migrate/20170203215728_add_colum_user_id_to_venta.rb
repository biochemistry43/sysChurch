class AddColumUserIdToVenta < ActiveRecord::Migration
  def change
  	add_column :ventas, :user_id, :integer
  end
end
