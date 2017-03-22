class AddNegocioToPresentacionProducto < ActiveRecord::Migration
  def change
  	add_column :presentacion_productos, :negocio_id, :integer
  end
end
