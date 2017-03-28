class AddNegocioToVenta < ActiveRecord::Migration
  def change
    add_column :ventas, :negocio_id, :integer
  end
end
