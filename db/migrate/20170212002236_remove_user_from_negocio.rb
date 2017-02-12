class RemoveUserFromNegocio < ActiveRecord::Migration
  def change
    remove_column :negocios, :user_id, :integer
  end
end
