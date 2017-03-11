class RemoveUserFromBanco < ActiveRecord::Migration
  def change
    remove_column :bancos, :user_id, :integer
  end
end
