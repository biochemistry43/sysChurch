class AddUsuarioToVentas < ActiveRecord::Migration
  def change
    add_column :ventas, :usuario_id, :integer
  end
end
