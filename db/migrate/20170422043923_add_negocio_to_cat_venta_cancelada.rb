class AddNegocioToCatVentaCancelada < ActiveRecord::Migration
  def change
    add_column :cat_venta_canceladas, :negocio_id, :integer
  end
end
