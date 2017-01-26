class AddUserToBanco < ActiveRecord::Migration
  def change
    add_column :bancos, :usuario_id, :integer
  end
end
