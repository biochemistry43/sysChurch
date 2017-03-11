class RemoveUsuarioFromBanco < ActiveRecord::Migration
  def change
    remove_column :bancos, :usuario_id, :integer
  end
end
