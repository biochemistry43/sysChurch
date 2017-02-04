class RemoveUsuarioIdFromVentas < ActiveRecord::Migration
  def change
    remove_column :ventas, :usuario_id, :integer
  end
end
